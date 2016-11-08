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

@end

@implementation XCZPublishSelectedCityView

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
        
        [headerLeftBtn addTarget:self action:@selector(headerLeftBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerRightBtn addTarget:self action:@selector(headerRightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.allProvince.count;
    } else if (component == 1) {
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
        NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        return cities.count;
    } else {
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
        NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        NSUInteger selectedTwoRow = [pickerView selectedRowInComponent:1];
        NSString *cityId = [cities[selectedTwoRow] objectForKey:@"number"];
        NSArray *towns = [XCZCityManager townNameForCityId:cityId];
        return towns.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    if (component == 0) {
        title = [self.allProvince[row] objectForKey:@"city"];
    } else if (component == 1) {
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
       NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        title = [cities[row] objectForKey:@"city"];
    } else {
        NSUInteger selectedOneRow = [pickerView selectedRowInComponent:0];
        NSString *provinceId = [self.allProvince[selectedOneRow] objectForKey:@"number"];
        NSArray *cities = [XCZCityManager citiesForProvinceId:provinceId];
        NSUInteger selectedTwoRow = [pickerView selectedRowInComponent:1];
        NSString *cityId = [cities[selectedTwoRow] objectForKey:@"number"];
        NSArray *towns = [XCZCityManager townNameForCityId:cityId];
        title = [towns[row] objectForKey:@"city"];
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    } else if (component == 1) {
        [pickerView reloadComponent:2];
    } else {
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
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
