//
//  PlacePickerViewController.h
//  2-dituhaha
//
//  Created by 企商汇 on 16/6/20.
//  Copyright © 2016年 qishanghui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@class PlacePickerViewController;

#pragma mark - 自定义导航条
@interface PPNavBar : UIView
/** 1.左边返回按钮 */
@property(nonatomic, strong)UIButton *leftBtn;
/** 2.右边按钮 */
@property(nonatomic, strong)UIButton *rigntBtn;
/** 3.设置标题 */
@property(nonatomic, copy)NSString *title;
/** 4.titleView */
@property(nonatomic, strong)UIButton *titleView;
/** 5.初始化导航条 */
+ (instancetype)navBar;
@end

#pragma mark - PPSearchView
@interface PPSearchView : UIView
/** 1.searchBar */
@property(nonatomic, strong)UISearchBar *searchBar;
@end

#pragma mark - PPAnnotationView
@interface PPAnnotationView : BMKPinAnnotationView
/**annotation view显示的title*/
@property(nonatomic, copy)NSString *title;
/** 2.颜色 */
@property(nonatomic, strong)UIColor *titleColor;
@end

#pragma mark - PlacePickerViewController
@protocol PlacePickerViewControllerDelegate <NSObject>
@required
- (void)placePickerController:(PlacePickerViewController *)placePickerController didFinishPickingPlace:(NSDictionary *)placeInfo;
@end

@interface PlacePickerViewController : UIViewController
@property (weak, nonatomic) id <PlacePickerViewControllerDelegate> delegate;
@property (nonatomic, copy) NSDictionary *serviceInfo;
@end
