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
        self.selectedTownId = _currentLocation[@"townid"];

//    if ([self.selectedProvinceId isEqual:[NSNull null]]) {
//        self.selectedProvinceId = @"";
//    }
//    if ([self.selectedCityId isEqual:[NSNull null]]) {
//        self.selectedCityId = @"";
//    }
//    if ([self.selectedTownId isEqual:[NSNull null]]) {
//        self.selectedTownId = @"";
//    }
//    if (!self.selectedProvinceId.length) {
//         self.selectedProvinceId = @"330000";
//    }
//    if (!self.selectedCityId.length) {
//        self.selectedCityId = @"331000";
//    }
//    if (!self.selectedTownId.length) {
//        self.selectedTownId = @"331001";
//    }
    for (NSDictionary *province in self.provinces) {
        if ([province[@"number"] isEqualToString:self.selectedProvinceId]) {
            [self.pickerView selectRow:[self.provinces indexOfObject:province] inComponent:0 animated:YES];
            break;
        }
    }
    
    for (NSDictionary *city in self.cities) {
        if ([city[@"number"] isEqualToString:self.selectedCityId]) {
            [self.pickerView selectRow:[self.cities indexOfObject:city] inComponent:1 animated:YES];
            break;
        }
    }
    
    for (NSDictionary *town in self.towns) {
        if ([town[@"number"] isEqualToString:self.selectedTownId]) {
            [self.pickerView selectRow:[self.towns indexOfObject:town] inComponent:2 animated:YES];
            break;
        }
    }
}



- (void)setSelectedProvinceId:(NSString *)selectedProvinceId {
    _selectedProvinceId = selectedProvinceId;
    [self.pickerView reloadComponent:0];
    
    for (NSDictionary *province in self.provinces) {
        if ([province[@"number"] isEqualToString:self.selectedProvinceId]) {
            [self.pickerView selectRow:[self.provinces indexOfObject:province] inComponent:0 animated:YES];
            break;
        }
    }
    
    self.cities = [XCZCityManager citiesForProvinceId:_selectedProvinceId];
    self.selectedCityId = [self.cities.firstObject objectForKey:@"number"];
    
    /*
    if (self.cities.count) {
        self.towns = [XCZCityManager townNameForCityId:[self.cities.firstObject objectForKey:@"number"]];
    }
     */
    // [self.pickerView reloadAllComponents];
    // [self.pickerView reloadComponent:0];

}

- (void)setSelectedCityId:(NSString *)selectedCityId {
    _selectedCityId = selectedCityId;
    [self.pickerView reloadComponent:1];

    for (NSDictionary *city in self.cities) {
        if ([city[@"number"] isEqualToString:self.selectedCityId]) {
            [self.pickerView selectRow:[self.cities indexOfObject:city] inComponent:1 animated:YES];
            break;
        }
    }
    
    self.towns = [XCZCityManager townNameForCityId:_selectedCityId];
    self.selectedTownId = [self.towns.firstObject objectForKey:@"number"];
    
    // [self.pickerView reloadComponent:1];
}

- (void)setSelectedTownId:(NSString *)selectedTownId {
    _selectedTownId = selectedTownId;
    [self.pickerView reloadComponent:2];

    for (NSDictionary *town in self.towns) {
        if ([town[@"number"] isEqualToString:self.selectedTownId]) {
            [self.pickerView selectRow:[self.towns indexOfObject:town] inComponent:2 animated:YES];
            break;
        }
    }

    // [self.pickerView reloadComponent:2];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.provinces.count;
    } else if (component == 1) {
        return self.cities.count;
    } else {
        return self.towns.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"title";
    if (component == 0) {
        title = [self.provinces[row] objectForKey:@"city"];
    } else if (component == 1) {
        title = [self.cities[row] objectForKey:@"city"];
    } else {
        title = [self.towns[row] objectForKey:@"city"];
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedProvinceId = [self.provinces[row] objectForKey:@"number"];
        
        /*
        NSArray *cities = [XCZCityManager citiesForProvinceId:_selectedProvinceId];
        self.selectedCityId = [[cities firstObject] objectForKey:@"number"];
        NSArray *towns = [XCZCityManager townNameForCityId:self.selectedCityId];
        self.selectedTownId = [[towns firstObject] objectForKey:@"number"];
         */
    } else if (component == 1) {
        self.selectedCityId = [self.cities[row] objectForKey:@"number"];
        
        /*
        NSArray *towns = [XCZCityManager townNameForCityId:self.selectedCityId];
        self.selectedTownId = [[towns firstObject] objectForKey:@"number"];
         */
    } else {
        self.selectedTownId = [self.towns[row] objectForKey:@"number"];
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
//    NSLog(@"selectedProvinceId:%@, selectedCityId:%@, selectedTownId:%@",  self.selectedProvinceId, self.selectedCityId, self.selectedTownId );
    /*
    NSDictionary *selectedProvinceDict = @{
                                            @"number": self.selectedProvinceId,
                                            @"city": [XCZCityManager provinceNameForProvinceId:self.selectedProvinceId]
                                           };
     */


    /*
    NSDictionary *selectedCityDict = @{
                                           @"number": self.selectedCityId ,
                                           @"city": [XCZCityManager cityNameForCityId:self.selectedCityId],
                                           };
     */
//    if (!self.selectedTownId.length) {
//       self.selectedTownId = [NSString stringWithFormat:@"%lld", [self.selectedCityId longLongValue] + 1];
//    }
    /*
    NSDictionary *selectedTownDict = @{
                                           @"number": self.selectedTownId,
                                           @"city": [XCZCityManager townNameForTownId:self.selectedTownId],
                                           };
     */
    
    NSDictionary *selectedProvinceDict = self.provinces[[self.pickerView selectedRowInComponent:0]];
    NSDictionary *selectedCityDict = self.cities[[self.pickerView selectedRowInComponent:1]];
    NSDictionary *selectedTownDict = self.towns[[self.pickerView selectedRowInComponent:2]];

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
