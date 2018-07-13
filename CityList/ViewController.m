//
//  ViewController.m
//  CityList
//
//  Created by chuck on 2018/7/11.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import "ViewController.h"
#import "CityListViewController.h"

@interface ViewController ()<CityListViewControllerDelegate>
@property (nonatomic,strong)UILabel *labe;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _labe = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 50, 30)];
    _labe.text = @"城市";
    _labe.textColor = [UIColor blueColor];
    _labe.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_labe];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 150, 40)];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"选择城市" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CityListViewController *cityVC = [[CityListViewController alloc]init];
    cityVC.delegate = self;
    [self.navigationController pushViewController:cityVC animated:YES];
}

-(void)selectCityName:(NSString *)cityName {
    _labe.text = cityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
