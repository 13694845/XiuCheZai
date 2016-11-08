//
//  XCZPublishPickerView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/10.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishSelectedCityView.h"
#import "XCZCityManager.h"

@interface XCZPublishSelectedCityView()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIButton *headerLeftBtn;
@property (nonatomic, weak) UIButton *headerRightBtn;
@property (nonatomic, weak) UIPickerView *pickerView;

// **********
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSArray *towns;
// **********

@end

@implementation XCZPublishSelectedCityView

// **********
- (void)setCurrentLocation:(NSDictionary *)currentLocation {
    _currentLocation = currentLocation;
    
    self.selectedProvinceId = _currentLocation[@"provinceid"];
    self.selectedCityId = _currentLocation[@"cityid"];
    // ...
    
    if (self.selectedProvinceId.length) {
        for (NSDictionary *province in self.provinces) {
            if (province[@"number"] == self.selectedProvinceId) {
                [self.pickerView selectRow:[self.provinces indexOfObject:province] inComponent:0 animated:YES];
            }
        }
    }
    for (NSDictionary *city in self.cities) {
        if (city[@"number"] == self.selectedCityId) {
            [self.pickerView selectRow:[self.cities indexOfObject:city] inComponent:1 animated:YES];
        }
    }
    // ... for town
}

- (void)setSelectedProvinceId:(NSString *)selectedProvinceId {
    _selectedProvinceId = selectedProvinceId;
    
    self.cities = [XCZCityManager citiesForProvinceId:_selectedProvinceId];
    if (self.cities.count) {
        self.towns = [XCZCityManager townNameForCityId:[self.cities.firstObject objectForKey:@"number"]];
    }
}

- (void)setSelectedCityId:(NSString *)selectedCityId {
    _selectedCityId = selectedCityId;
    
    self.towns = [XCZCityManager townNameForCityId:_selectedCityId];
}

- (void)setSelectedTownId:(NSString *)selectedTownId {
    _selectedTownId = selectedTownId;
}

- (NSArray *)provinces {
    if (!_provinces) _provinces = [[XCZCityManager allProvince] copy];
    return _provinces;
}

- (NSArray *)cities {
    if (!_cities) _cities = [NSArray array];
    return _cities;
}

- (NSArray *)towns {
    if (!_towns) _towns = [NSArray array];
    return _towns;
}
// **********

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.headerView
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 45)];
        headerView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        [self addSubview:headerView];
        self.headerView = headerView;
        
        CGFloat headerBtnW = 50;
        UIButton *headerLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, headerBtnW, headerView.frame.size.height)];
        headerLeftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [headerLeftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [headerLeftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [headerView addSubview:headerLeftBtn];
        self.headerLeftBtn = headerLeftBtn;
        
        CGFloat headerRightBtnX = frame.size.width - headerBtnW;
        UIButton *headerRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerRightBtnX, 0, headerBtnW, headerView.frame.size.height)];
        headerRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [headerRightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [headerRightBtn setTitleColor:[UIColor colorWithRed:50/255.0 green:150/255.0 blue:250/255.0 alpha:1.0] forState:UIControlStateNormal];
        [headerView addSubview:headerRightBtn];
        self.headerRightBtn = headerRightBtn;
        
        // 2.pickerView
        CGFloat pickerViewY = CGRectGetMaxY(headerView.frame);
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, pickerViewY, frame.size.width, frame.size.height - pickerViewY)];
        pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:pickerView];
        self.pickerView = pickerView;
        // **********
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        // **********
        
        [headerLeftBtn addTarget:self action:@selector(headerLeftBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerRightBtn addTarget:self action:@selector(headerRightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

/*
- (void)setAllProvince:(NSArray *)allProvince
{
    _allProvince = allProvince;
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    if (self.currentPositioning) {
        NSInteger oneRow = 0;
        NSInteger twoRow = 0;
        NSInteger threeRow = 0;
        for (int i = 0; i<allProvince.count; i++) {
            if ([[allProvince[i] objectForKey:@"number"] isEqualToString:self.currentPositioning[@"provinceid"]]) {
                NSArray *cities = [XCZCityManager citiesForProvinceId:self.currentPositioning[@"provinceid"]];
                oneRow = i;
                for (int j = 0; j<cities.count; j++) {
                    if ([[cities[j] objectForKey:@"number"] isEqualToString:self.currentPositioning[@"cityid"]]) {
                        NSArray *towns = [XCZCityManager townNameForCityId:self.currentPositioning[@"cityid"]];
                        twoRow = j;
                        for (int k = 0; k<towns.count; k++) {
                            if ([[towns[k] objectForKey:@"number"] isEqualToString:self.currentPositioning[@"areaid"]]) {
                                threeRow = k;
                            }
                        }
                        
                    }
                }
            }
        }
        [self.pickerView selectRow:oneRow inComponent:0 animated:NO];
        [self.pickerView selectRow:twoRow inComponent:1 animated:NO];
        [self.pickerView selectRow:threeRow inComponent:2 animated:NO];
    }
    
    [self.pickerView reloadAllComponents];
}
 */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.provinces.count;
    } else if (component == 1) {
        /*
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
         */
        // self.cities = [XCZCityManager citiesForProvinceId:self.selectedProvinceId];
        return self.cities.count;
    } else {
        /*
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
        NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        NSUInteger selectedTwoRow = [pickerView selectedRowInComponent:1];
        NSString *cityId = [cities[selectedTwoRow] objectForKey:@"number"];
         */
        // self.towns = [XCZCityManager townNameForCityId:self.selectedCityId];
        return self.towns.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"title";
    if (component == 0) {
        title = [self.provinces[row] objectForKey:@"city"];
    } else if (component == 1) {
        /*
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
         */
        // self.cities = [XCZCityManager citiesForProvinceId:self.selectedProvinceId];
        title = [self.cities[row] objectForKey:@"city"];
    } else {
        /*
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
        NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        NSUInteger selectedTwoRow = [pickerView selectedRowInComponent:1];
        NSString *cityId = [cities[selectedTwoRow] objectForKey:@"number"];
         */
        // self.towns = [XCZCityManager townNameForCityId:self.selectedCityId];
        title = [self.towns[row] objectForKey:@"city"];
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        // **********
        self.selectedProvinceId = [self.provinces[row] objectForKey:@"number"];
        [pickerView reloadAllComponents];
        /*
        self.cities = [XCZCityManager citiesForProvinceId:self.selectedProvinceId];
        if (self.cities.count) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView reloadComponent:1];
        }
        
        if (self.cities.count) {
            self.selectedCityId = [self.cities.firstObject objectForKey:@"number"];
            self.towns = [XCZCityManager townNameForCityId:self.selectedCityId];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        }
         */
        // **********
    } else if (component == 1) {
        // **********
        self.selectedCityId = [self.cities[row] objectForKey:@"number"];
        [pickerView reloadComponent:2];
        /*
        self.towns = [XCZCityManager townNameForCityId:self.selectedCityId];
        if (self.towns.count) {
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        }
         */
        // **********
    } else {
        /*
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
         */
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (void)headerLeftBtnDidClick:(UIButton *)leftBtn
{
    if ([self.delegate respondsToSelector:@selector(publishSelectedCityView:headerLeftBtnDidClick:)]) {
        [self.delegate publishSelectedCityView:self headerLeftBtnDidClick:leftBtn];
    }
}

- (void)headerRightBtnDidClick:(UIButton *)rightBtn
{
    NSInteger oneRow = [self.pickerView selectedRowInComponent:0];
    NSDictionary *selectedProvinceDict = self.allProvince[oneRow];
    
    NSString *provinceId = [selectedProvinceDict objectForKey:@"number"];
    NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
    NSInteger twoRow = [self.pickerView selectedRowInComponent:1];
    NSDictionary *selectedCityDict = cities[twoRow];
    
    NSString *cityId = [selectedCityDict objectForKey:@"number"];
    NSArray *towns = [XCZCityManager townNameForCityId:cityId];
    NSInteger threeRow = [self.pickerView selectedRowInComponent:2];
    NSDictionary *selectedTownDict = towns[threeRow];
    
    NSDictionary *selectedLocation = @{
                                           @"selectedProvinceDict": selectedProvinceDict,
                                           @"selectedCityDict": selectedCityDict,
                                           @"selectedTownDict": selectedTownDict,
                                       };
    if ([self.delegate respondsToSelector:@selector(publishSelectedCityView:headerRightBtnDidClickWithSelectedLocation:)]) {
        [self.delegate publishSelectedCityView:self headerRightBtnDidClickWithSelectedLocation:selectedLocation];
    }
}

@end
