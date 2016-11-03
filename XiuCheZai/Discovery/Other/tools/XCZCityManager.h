//
//  XCZCityManager.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/10/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZCityManager : NSObject

/**
 *  返回所有省
 */
+ (NSArray *)allProvince;

/**
 *  根据省ID，返回省名
 */
+ (NSString *)provinceNameForProvinceId:(NSString *)provinceId;

/**
 *  根据省ID，返回该省所有的地级市字典素组
 */
+ (NSArray *)citiesForProvinceId:(NSString *)provinceId;

/**
 *  根据地级市ID，返回该市名称
 */
+ (NSString *)cityNameForCityId:(NSString *)cityId;
//
/**
 *  根据地级市ID，返回该市下面所有的县(包括县级市，区)字典数组
 */
+ (NSArray *)townNameForCityId:(NSString *)cityId;

/**
 *  根据县ID，返回该县名称
 */
+ (NSString *)townNameForTownId:(NSString *)townId;

/**
 *  返回所有拼音排序过的市
 */
+ (NSArray *)allPinyin;

/**
 *  拼接省市区名称1(传入名称)
 */
+ (NSString *)splicingProvinceCityTownNameWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName andTownName:(NSString *)townName;

/**
 *  拼接省市区名称2(传入Id)
 */
+ (NSString *)splicingProvinceCityTownNameWithProvinceId:(NSString *)provinceId cityId:(NSString *)cityId andTownId:(NSString *)townId;

@end
