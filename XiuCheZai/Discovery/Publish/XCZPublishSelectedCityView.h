//
//  XCZPublishPickerView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/10.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPublishSelectedCityView;

@protocol XCZPublishSelectedCityViewDelegate <NSObject>

@optional
- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerLeftBtnDidClick:(UIButton *)leftBtn;
- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerRightBtnDidClickWithSelectedLocation:(NSDictionary *)selectedLocation;

@end

@interface XCZPublishSelectedCityView : UIView

@property (nonatomic, strong) NSArray *allProvince;
@property (nonatomic, strong) NSDictionary *currentPositioning;
@property (nonatomic, weak) id<XCZPublishSelectedCityViewDelegate> delegate;

// **********
@property (nonatomic, strong) NSDictionary *currentLocation;


@property (nonatomic, strong) NSString *selectedProvinceId;
@property (nonatomic, strong) NSString *selectedCityId;
@property (nonatomic, strong) NSString *selectedTownId;
// **********

@end
