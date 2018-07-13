//
//  CityListViewController.h
//  CityList
//
//  Created by chuck on 2018/7/11.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CityListViewControllerDelegate <NSObject>
@optional
- (void)selectCityName:(NSString *)cityName;

@end

@interface CityListViewController : UIViewController

@property(nonatomic,weak)id<CityListViewControllerDelegate> delegate;

@end
