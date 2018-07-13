//
//  CityListDefultData.m
//  CityList
//
//  Created by chuck on 2018/7/13.
//  Copyright © 2018年 chuck. All rights reserved.
//

#import "CityListDefultData.h"

@implementation CityListDefultData
static CityListDefultData* _instance = nil;

+(instancetype) defultCityList
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    return [CityListDefultData defultCityList];
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [CityListDefultData defultCityList] ;
}

@end
