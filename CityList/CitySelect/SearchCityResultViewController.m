//
//  SearchCityResultViewController.m
//  CityList
//
//  Created by chuck on 2018/7/11.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import "SearchCityResultViewController.h"
static NSString *cellid = @"cellid";

@interface SearchCityResultViewController ()
<
UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource
>

@property(nonatomic,strong)UISearchBar *searchBar;

@property(nonatomic,strong)UITableView *tableView;

@property (nonatomic,copy)NSArray *data;

@end

@implementation SearchCityResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, 40)];
//    searchBar.placeholder = @"请输入中文城市名称";
//    self.navigationItem.titleView = searchBar;
//    _searchBar = searchBar;
//    _searchBar.delegate = self;
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(customBack)];
    
    
    self.tableView.frame = self.view.bounds;
}

-(UITableView *)tableView {
    if (_tableView==nil) {
        _tableView = [[UITableView alloc]init];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellid];
    }
    return _tableView;
}

- (void)customBack {
    [self.searchBar resignFirstResponder];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
//    [_searchBar becomeFirstResponder];
}

#pragma mark ---UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = searchBar.text;
    [self searchText:text];
}

- (void)searchText:(NSString *)inputStr {
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSArray *arr in _dataArray) {
        for (NSDictionary *dic in arr) {
            NSString *dicStr = [dic objectForKey:@"name"];
            if ([dicStr isEqualToString:inputStr] || [dicStr containsString:inputStr]) {
                [arrM addObject:dicStr];
            }
        }
    }
    _data = arrM.copy;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark ---UITableViewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    [cell.textLabel setText:_data[indexPath.row]];
    if (_data.count > 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = _data[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResult:)]) {
        [self.delegate searchResult:string];
        [self customBack];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
