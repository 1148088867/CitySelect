//
//  CityListViewController.m
//  CityList
//
//  Created by chuck on 2018/7/11.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import "CityListViewController.h"
#import "BMChineseSort.h"
#import "CityHeaderView.h"
#import "TLCityGroupCell.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchCityResultViewController.h"
#import "TLCityPickerDelegate.h"
#import "HXSearchBar.h"

#define ScreenBounds [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, ZJCityLocationState) {
    ZJCityLocationStateIslocating,
    ZJCityLocationStateLocationFail,
    ZJCityLocationStateLocationSuccess
};

static NSString *cellid = @"cellid";
static NSString *headerid = @"headerid";

@interface CityListViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
SearchCityResultViewControllerDelegate,
TLCityGroupCellDelegate
>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,copy)NSArray *data;
@property(nonatomic,strong)NSMutableArray *indexArray;
@property(nonatomic,strong)NSMutableArray *letterResultArr;
//选择城市
@property(nonatomic,copy)NSArray *selectCity;

@property(nonatomic,copy)NSArray *hotCityData;

@property (assign, nonatomic) ZJCityLocationState locationState;
@property (strong, nonatomic) CLLocationManager *locManager;//获取用户位置
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (copy, nonatomic) NSString *locationCityName;

@property (nonatomic,copy)NSDictionary *locationCity;
@property (nonatomic,copy)NSArray *locationCityArr;

@property (nonatomic,strong)HXSearchBar *searchBar;
@property (nonatomic,strong)SearchCityResultViewController *searchVC;

@end

@implementation CityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    self.navigationItem.titleView = self.searchBar;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(customBack)];
    
    self.tableView.frame = self.view.frame;
    [self beginGetLocation];
    self.hotCityData = @[@"北京",@"上海",@"杭州",@"厦门",@"宁波",@"温州",@"台州",@"绍兴"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self outPutSelectCity];
}

-(HXSearchBar *)searchBar {
    if (!_searchBar) {
        //加上 搜索栏
        HXSearchBar *searchBar = [[HXSearchBar alloc] initWithFrame:CGRectMake(50, 4, ScreenWidth - 50 - 40, 36)];
        searchBar.backgroundColor = [UIColor clearColor];
        //输入框提示
        searchBar.placeholder = @"搜索城市名称";
        
        //光标颜色
        searchBar.cursorColor = [UIColor redColor];
        //TextField
        searchBar.searchBarTextField.layer.cornerRadius = 4;
        searchBar.searchBarTextField.layer.masksToBounds = YES;
        searchBar.searchBarTextField.layer.borderColor = [UIColor grayColor].CGColor;
        searchBar.searchBarTextField.layer.borderWidth = 1.0;
        
        //清除按钮图标
        searchBar.clearButtonImage = [UIImage imageNamed:@"icon_quxiao"];
        
        //去掉取消按钮灰色背景
        searchBar.hideSearchBarBackgroundImage = YES;
        _searchBar = searchBar;
    }
    _searchBar.delegate = self;
    return _searchBar;
}


-(void)setSelectCity:(NSArray *)selectCity {
    _selectCity = selectCity.copy;
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self outPutSelectCity];
}

- (void)outPutSelectCity {
    NSString *selectCityName ;
    if ([_selectCity.firstObject isKindOfClass:[NSString class]]) {
        selectCityName = _selectCity.firstObject;
    }
    if ([_selectCity.firstObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = _selectCity.firstObject;
        selectCityName = [dic objectForKey:@"name"];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectCityName:)]) {
        [self.delegate selectCityName:selectCityName];
    }
}

- (void)customBack {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (CLLocationManager *)locManager{
    if (!_locManager) {
        CLLocationManager *locManager = [CLLocationManager new];
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        locManager.distanceFilter = kCLDistanceFilterNone;
        _locManager = locManager;
    }
    return _locManager;
}

- (CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

// 开始定位
- (void)beginGetLocation {
    
    [self.locManager requestWhenInUseAuthorization];
    
    __weak typeof(self) weakSelf = self;
    [self.geocoder reverseGeocodeLocation:self.locManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        [weakSelf.locManager stopUpdatingLocation];
        if (error || placemarks.count == 0) {
            weakSelf.locationState = ZJCityLocationStateLocationFail;
        }else{
            weakSelf.locationState = ZJCityLocationStateLocationSuccess;
            
            CLPlacemark *currentPlace = [placemarks firstObject];
            weakSelf.locationCityName = currentPlace.locality;
            
        }
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(reloadLocationCity) userInfo:nil repeats:NO];
    }];
}

// 刷新定位城市的section == 0
- (void)reloadLocationCity {
    self.locationCity = [self selectCityInfo];
    if (_selectCity == nil) {
        _selectCity = _locationCityArr;
    }
    [self.tableView reloadData];
}


- (NSDictionary *)selectCityInfo {
    for (int i = 0; i < _letterResultArr.count; i ++) {
        NSArray *arr = _letterResultArr[i];
        for (int j = 0; j < arr.count; j ++) {
            NSDictionary *dic = arr[j];
            if ([self.locationCityName isEqualToString:[dic valueForKey:@"name"]]) {
                _locationCity = dic.copy;
                self.locationCityArr = [NSArray arrayWithObject:dic];
                return dic;
            }
        }
    }
    _locationCity = nil;
    
    return nil;
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.data == nil) {
            NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newAddress" ofType:@"plist"]];
            NSMutableArray *data = [[NSMutableArray alloc] init];
            for (NSDictionary *groupDic in array) { //省
                NSArray *cityArray = [groupDic objectForKey:@"child"];
                
                //1、
                for (NSDictionary *cityDic in cityArray) {
                    [data addObject:@{@"name":[cityDic objectForKey:@"name"]}];
                }
                //2、
//                [data addObjectsFromArray:cityArray];
            }
            self.data = data.copy;
            self.indexArray = [BMChineseSort IndexWithArray:data Key:@"name"];
            self.letterResultArr = [BMChineseSort sortObjectArray:data Key:@"name"];
        }
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self reloadLocationCity];
        });
    });
}


-(UITableView *)tableView {
    if (_tableView==nil) {
        _tableView = [[UITableView alloc]init];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellid];
        [_tableView registerClass:[CityHeaderView class] forHeaderFooterViewReuseIdentifier:headerid];
        [self.tableView registerClass:[TLCityGroupCell class] forCellReuseIdentifier:@"TLCityGroupCell"];
    }
    return _tableView;
}

-(SearchCityResultViewController *)searchVC {
    if (!_searchVC) {
        SearchCityResultViewController *searchVC = [[SearchCityResultViewController alloc]init];
        searchVC.indexArray = _indexArray.copy;
        searchVC.dataArray = _letterResultArr.copy;
        searchVC.delegate = self;
        _searchVC = searchVC;
    }
    return _searchVC;
}

#pragma mark ---UISearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    _searchBar.cancleButton.backgroundColor = [UIColor clearColor];
    [_searchBar.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [_searchBar.cancleButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _searchBar.cancleButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_searchBar.cancleButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addChildViewController:self.searchVC];
    [self.view addSubview:self.searchVC.view];
    self.searchVC.view.alpha = 0.5;
    return YES;
}

- (void)cancelSearch {
//    [_searchBar resignFirstResponder];
    for (id obj in self.childViewControllers) {
        if ([obj isKindOfClass:[SearchCityResultViewController class]]) {
            SearchCityResultViewController *vc = obj;
            [vc dismissViewControllerAnimated:NO completion:nil];
            [vc.view removeFromSuperview];
        }
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchVC.indexArray = _indexArray.copy;
    _searchVC.dataArray = _letterResultArr.copy;
    [self.searchVC searchText:searchText];
    _searchVC.view.alpha = 1;
}

//取消按钮点击的回调
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [self.view endEditing:YES];
}

#pragma  mark ---SearchCityResultViewControllerDelegate
-(void)searchResult:(NSString *)string {
    self.selectCity = [NSArray arrayWithObject:string];
}

#pragma mark ---UITableViewDelegate && UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexArray.count + 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < 3) {
        return 1;
    }
    return [[self.letterResultArr objectAtIndex:section-3] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 3) {
        TLCityGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLCityGroupCell"];
        if (indexPath.section == 0) {
            [cell setTitle:@"当前城市："];
            [cell setCityArray:_locationCityArr];
            
        }
        else if (indexPath.section == 1) {
            [cell setTitle:@"已选位置"];
            [cell setCityArray:_selectCity];
            
        }
        else {
            [cell setTitle:@"热门城市"];
            [cell setCityArray:self.hotCityData];
        }
        [cell setDelegate:self];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    NSDictionary *dic = [[self.letterResultArr objectAtIndex:indexPath.section - 3] objectAtIndex:indexPath.row];
    NSString *name = [dic valueForKey:@"name"];
    [cell.textLabel setText:name];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < 3) {
        return nil;
    }
    CityHeaderView *headerV = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerid];
    NSString *title = [_indexArray objectAtIndex: section -3 ];
    [headerV setTitle:title];
    return headerV;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section < 3) {
        return 0.f;
    }
    return 40.f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [TLCityGroupCell getCellHeightOfCityArray:self.locationCityArr];
    }
    else if (indexPath.section == 1) {
        return [TLCityGroupCell getCellHeightOfCityArray:_selectCity];
    }
    else if (indexPath.section == 2){
        return [TLCityGroupCell getCellHeightOfCityArray:self.hotCityData];
    }
    return 43.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 3) {
        if (indexPath.section == 1) {
        }else if(indexPath.section == 0){
            _selectCity = _locationCityArr;
        }else {
//            _selectCity =
        }
    }else {
        NSArray *arr = [_letterResultArr objectAtIndex:indexPath.section - 3];
        self.selectCity = [NSArray arrayWithObject:[arr objectAtIndex:indexPath.row]];
    }
}

#pragma mark ---TLCityGroupCellDelegate
-(void)cityGroupCellDidSelectCity:(id)city {
    _selectCity = [NSArray arrayWithObject:city];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
