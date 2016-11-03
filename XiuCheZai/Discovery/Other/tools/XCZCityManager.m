//
//  XCZCityManager.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/10/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCityManager.h"

@interface XCZCityManager()


@end

@implementation XCZCityManager

+ (NSArray *)allProvince {
    NSDictionary *dict = [self jsonToDictWithName:@"Province" andType:@"json"];
    NSMutableArray *provinces = [NSMutableArray array];
    return [self dictToArray:provinces andDict:dict];
}

+ (NSString *)provinceNameForProvinceId:(NSString *)provinceId {
    return [[self jsonToDictWithName:@"Province" andType:@"json"] objectForKey:provinceId];
}

+ (NSArray *)citiesForProvinceId:(NSString *)provinceId {
    NSDictionary *dict = [[self jsonToDictWithName:@"City" andType:@"json"] objectForKey:provinceId];
    NSMutableArray *cities = [NSMutableArray array];
    return [self dictToArray:cities andDict:dict];
}

+ (NSString *)cityNameForCityId:(NSString *)cityId {
    NSString *cityName;
    for (NSDictionary *dict in [[self jsonToDictWithName:@"City" andType:@"json"] allValues]) {
        for (NSString *key in [dict allKeys]) {
            if ([key isEqualToString:cityId]) {
                cityName = [dict objectForKey:key];
            }
        }
    }
    return cityName;
}

+ (NSArray *)townNameForCityId:(NSString *)cityId {
    NSDictionary *dict = [[self jsonToDictWithName:@"Town" andType:@"json"] objectForKey:cityId];
    NSMutableArray *cities = [NSMutableArray array];
    return [self dictToArray:cities andDict:dict];
}

+ (NSString *)townNameForTownId:(NSString *)townId {
    NSString *townName;
    for (NSDictionary *dict in [[self jsonToDictWithName:@"Town" andType:@"json"] allValues]) {
        for (NSString *key in [dict allKeys]) {
            if ([key isEqualToString:townId]) {
                townName = [dict objectForKey:key];
            }
        }
    }
    return townName;
}

+ (NSArray *)allPinyin {	// 返回所有拼音排序过的市
    NSDictionary *dict = [self jsonToDictWithName:@"Pinyin" andType:@"json"];
    NSMutableArray *cities = [NSMutableArray array];
    for (NSString *key in [dict allKeys]) {
        NSDictionary *value = [dict objectForKey:key];
        
        NSMutableDictionary *mcities = [NSMutableDictionary dictionary];
        NSMutableArray *vCities = [NSMutableArray array];
        for (NSString *vKey in [value allKeys]) {
            NSMutableDictionary *mliCity = [NSMutableDictionary dictionary];
            [mliCity addEntriesFromDictionary:[NSDictionary dictionaryWithObject:vKey forKey:@"id"]];
            [mliCity addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[value objectForKey:vKey] forKey:@"name"]];
            [vCities addObject:mliCity];
        }
        vCities = [[vCities sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]] mutableCopy];
        
        [mcities addEntriesFromDictionary:[NSDictionary dictionaryWithObject:key forKey:@"number"]];
        [mcities addEntriesFromDictionary:[NSDictionary dictionaryWithObject:vCities forKey:@"city"]];
        [cities addObject:mcities];
    }
    
    return [cities sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
}

/**
 *  拼接省市区名称1(传入名称)
 */
+ (NSString *)splicingProvinceCityTownNameWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName andTownName:(NSString *)townName
{
    NSString *addr;
    if ([cityName isEqualToString:provinceName]) { // 省市名称相等时
        if (!cityName.length) {
            addr = [townName isEqualToString:cityName] ? @"" : townName;
        } else {
            if ([townName isEqualToString:cityName]) {
                addr = cityName;
            } else {
                addr = !townName.length ? provinceName : [NSString stringWithFormat:@"%@%@", provinceName, townName];
            }
        }
    } else { // 省市名称不相等时
        if (!provinceName.length) { // 省市名称不相等时且省为空时
            if (!cityName.length) {
                addr = !townName.length ? @"": townName;
            } else {
                if ([townName isEqualToString:cityName]) {
                    addr = !townName.length ? @"": cityName;
                } else {
                    addr = !townName.length ? cityName : [NSString stringWithFormat:@"%@%@", cityName, townName];
                }
            }
        } else { // 省市名称不相等时且省不为空时
            if (!cityName.length) { // 省市名称不相等时且省不为空时,市为空时
                if ([provinceName isEqualToString:townName]) {
                    addr = townName;
                } else {
                    addr = !townName.length ? [NSString stringWithFormat:@"%@", provinceName] : [NSString stringWithFormat:@"%@%@", provinceName, townName];
                }
            } else { // 省市名称不相等时且省不为空,市不为空时
                if ([townName isEqualToString:cityName]) {
                    addr = [NSString stringWithFormat:@"%@%@", provinceName, cityName];
                } else {
                    addr = !townName.length ? [NSString stringWithFormat:@"%@%@", provinceName, cityName] : [NSString stringWithFormat:@"%@%@%@", provinceName, cityName, townName];
                }
            }
        }
    }
    return addr;
}

/**
 *  拼接省市区名称2(传入Id)
 */
+ (NSString *)splicingProvinceCityTownNameWithProvinceId:(NSString *)provinceId cityId:(NSString *)cityId andTownId:(NSString *)townId
{
    return [self splicingProvinceCityTownNameWithProvinceName:[self provinceNameForProvinceId:provinceId] cityName:[self cityNameForCityId:cityId] andTownName:[self townNameForTownId:townId]];
}

#pragma mark - 私有方法
+ (NSDictionary *)jsonToDictWithName:(NSString *)name andType:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
}

+ (NSArray *)dictToArray:(NSMutableArray *)provinces andDict:(NSDictionary *)dict
{
    for (NSString *key in [dict allKeys]) {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        [mDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:key forKey:@"number"]];
        [mDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[dict objectForKey:key] forKey:@"city"]];
        [provinces addObject:mDict];
    }
    return [provinces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
}

/**
 *  数组排序(升序):冒泡排序法
 */
+ (NSArray *)sortedWithArray:(NSMutableArray *)array
{
    int i, j;
    NSDictionary *temp;
    for (j = 0; j< array.count; j++) {
        for (i = 0; i<array.count - 1 - j; i++) {
            if ([[[array[i] allKeys] firstObject] integerValue] > [[[array[i+1] allKeys] firstObject] integerValue]) {
                temp = array[i];
                array[i] = array[i + 1];
                array[i + 1] = temp;
            }
        }
    }
    return array;
}

@end
