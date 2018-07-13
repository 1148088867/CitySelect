//
//  SearchCityResultViewController.h
//  CityList
//
//  Created by chuck on 2018/7/11.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchCityResultViewControllerDelegate <NSObject>
@optional
- (void)searchResult:(NSString *)string;
@end

@interface SearchCityResultViewController : UIViewController
@property (nonatomic,copy)NSArray *indexArray;
@property (nonatomic,copy)NSArray *dataArray;
@property (nonatomic,weak)id <SearchCityResultViewControllerDelegate>delegate;

- (void)searchText:(NSString *)inputStr;
@end
