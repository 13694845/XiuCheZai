//
//  PlacePickerViewController.m
//  2-dituhaha
//
//  Created by 企商汇 on 16/6/20.
//  Copyright © 2016年 qishanghui. All rights reserved.
//


#define PlacePickerViewControllerBackTypeBlank 0
#define PlacePickerViewControllerBackTypePoi 1

#import "PlacePickerViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>

#pragma mark - 自定义导航条
@implementation PPNavBar
+ (instancetype)navBar
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
        
        self.leftBtn = [[UIButton alloc] init];
        self.leftBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.leftBtn setTitle:@"返回" forState:UIControlStateNormal];
        [self addSubview:self.leftBtn];
        
        self.rigntBtn = [[UIButton alloc] init];
        self.rigntBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.rigntBtn];
        
        self.titleView = [[UIButton alloc] init];
        self.titleView.titleLabel.numberOfLines = 2;
        self.titleView.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleView.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleView.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.titleView];
        
        [self.leftBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.rigntBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.titleView setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat screewW = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat marginX = 5;
    CGFloat leftBtnW = 60;
    CGFloat leftBtnH = 30;
    CGFloat leftBtnX = marginX;
    CGFloat leftBtnY = statusH + (self.frame.size.height - statusH - leftBtnH) * 0.5;
    self.leftBtn.frame = CGRectMake(leftBtnX, leftBtnY, leftBtnW, leftBtnH);
    
    CGFloat rigntBtnW = 80;
    CGFloat rigntBtnH = 30;
    CGFloat rigntBtnX = screewW - marginX - rigntBtnW;
    CGFloat rigntBtnY = statusH + (self.frame.size.height - statusH - rigntBtnH) * 0.5;
    self.rigntBtn.frame = CGRectMake(rigntBtnX, rigntBtnY, rigntBtnW, rigntBtnH);
    
    CGFloat titleViewW = screewW - leftBtnW - rigntBtnW - 4 * marginX;
    CGFloat titleViewH = 30;
    CGFloat titleViewX = (screewW - titleViewW) * 0.5;
    CGFloat titleViewY = statusH + (self.frame.size.height - statusH - titleViewH) * 0.5;
    self.titleView.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleView setTitle:title forState:UIControlStateNormal];
}
@end

#pragma mark - PPSearchView
@implementation PPSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0];
        
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.backgroundImage = [[UIImage alloc] init];
        [self addSubview:self.searchBar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.searchBar.frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.bounds.size.width, 44);
}
@end

#pragma mark - PPAnnotationView
@interface PPAnnotationView()
/** 1.ppLabel */
@property(nonatomic, strong)UILabel *ppLabel;
@end

@implementation PPAnnotationView
- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.ppLabel = [[UILabel alloc] init];
        self.ppLabel.font = [UIFont systemFontOfSize:10];
        self.ppLabel.numberOfLines = 0;
        self.ppLabel.backgroundColor = [UIColor clearColor];
        self.ppLabel.textColor = [UIColor redColor];
        [self addSubview:self.ppLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.ppLabel.text = title;
    CGSize maxPPSize = CGSizeMake(100, MAXFLOAT);
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10]};
    CGSize ppSize = [self.ppLabel.text boundingRectWithSize:maxPPSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGFloat ppLabelX = -ppSize.width * 0.5 + self.bounds.size.width * 0.5;
    self.ppLabel.frame = CGRectMake(ppLabelX, self.bounds.size.height, ppSize.width, ppSize.height);
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.ppLabel.textColor = titleColor;
}
@end

#pragma mark - PlacePickerViewController
@interface PlacePickerViewController ()<BMKPoiSearchDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, BMKRouteSearchDelegate>
{
    int curPage;
    int backType; // 点击的类型
    BMKMapManager *_mapManager; // 引擎
    CLLocationCoordinate2D clickCoordinate2D; // 点击的地址经纬度
    
}

/** 0.自己的navBar */
@property(nonatomic, strong)PPNavBar *myNavBar;
/** 1.搜索框View */
@property(nonatomic, strong)PPSearchView *searchView;
/** 2.地图mapView */
@property(nonatomic, strong)BMKMapView *mapView;
/** 3.地位服务locService */
@property(nonatomic, strong)BMKLocationService *locService;
/** 4.商家点大头针Annotation */
@property(nonatomic, strong)BMKPointAnnotation *storePointAnnotation;
/** 5.取车点大头针Annotation */
@property(nonatomic, strong)BMKPointAnnotation *picUpCarPointAnnotation;
/** 6.定位大头针Annotation */
@property(nonatomic, strong)BMKPointAnnotation *locationAnnotation;
/** 7.取车点大头针View */
@property(nonatomic, strong)PPAnnotationView *picAnnotationView;
/** 8.取车点覆盖物 */
@property(nonatomic, strong)BMKCircle *picUpCarCircle;
/** 9.商家覆盖物 */
@property(nonatomic, strong)BMKCircle *storeCircle;
/** 10.商家覆盖物外圈 */
@property(nonatomic, strong)BMKCircle *storeWCircle;
/** 11.geo检索 */
@property(nonatomic, strong)BMKGeoCodeSearch *geoCodeSearch;
/** 12.poi检索 */
@property(nonatomic, strong)BMKPoiSearch *poisearch;
/** 13.显示信息View */
@property(nonatomic, strong)UITableView *showInfoView;
/** 14.附近城市信息 */
@property(nonatomic, strong)NSArray *poiList;
/** 15.coordRegion */
@property(nonatomic, assign)BMKCoordinateRegion coordRegion;
/** 16.反geo请求Option */
@property(nonatomic, strong)BMKReverseGeoCodeOption *reverseGeocodeSearchOption;
/** 17.周边检索Option */
@property(nonatomic, strong)BMKNearbySearchOption *nearBySearchOption;
/** 17.2.路径规划 */
@property(nonatomic, strong)BMKDrivingRoutePlanOption *routePlanOption;
/** 18.搜索点数组 */
@property(nonatomic, strong)NSMutableArray *searchPointArray;
/** 19.返回代理的字典 */
@property(nonatomic, strong)NSDictionary *placeDict;
/** 20.路径规划数组 */
@property(nonatomic, strong)NSMutableArray *routePointArray;
/** 21.路径规划View数组 */
@property(nonatomic, strong)NSMutableArray *routePointViewArray;

@end

@implementation PlacePickerViewController


- (NSDictionary *)placeDict
{
    if (_placeDict == nil) {
        _placeDict = [NSDictionary dictionary];
    }
    return _placeDict;
}

- (BMKReverseGeoCodeOption *)reverseGeocodeSearchOption
{
    if (_reverseGeocodeSearchOption == nil) {
        _reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    }
    return _reverseGeocodeSearchOption;
}

- (BMKNearbySearchOption *)nearBySearchOption
{
    if (_nearBySearchOption == nil) {
        _nearBySearchOption = [[BMKNearbySearchOption alloc] init];
    }
    return _nearBySearchOption;
}

- (BMKDrivingRoutePlanOption *)routePlanOption
{
    if (_routePlanOption == nil) {
        _routePlanOption = [[BMKDrivingRoutePlanOption alloc] init];
    }
    return _routePlanOption;
}

- (NSMutableArray *)searchPointArray
{
    if (_searchPointArray == nil) {
        _searchPointArray = [[NSMutableArray alloc] init];
    }
    return _searchPointArray;
}

- (NSMutableArray *)routePointArray
{
    if (_routePointArray == nil) {
        _routePointArray = [[NSMutableArray alloc] init];
    }
    return _routePointArray;
}

- (NSMutableArray *)routePointViewArray
{
    if (_routePointViewArray == nil) {
        _routePointViewArray = [[NSMutableArray alloc] init];
    }
    return _routePointViewArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self assistedSetup]; // 辅助设置(主要处理navBar等)
    [self setupSearchBar]; // 初始化搜索框
    [self setupMapManager];
    [self setupShowInfoView]; // 添加显示信息View
    [self setupLocation]; // 初始化定位
    [self setupSearch]; // 初始化检索
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    self.locService.delegate = self;
    self.geoCodeSearch.delegate = self;
    self.poisearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    self.locService.delegate = nil;
    self.geoCodeSearch.delegate = nil;
    self.poisearch.delegate = nil;
}

/**
 *  辅助设置(主要处理navBar等)
 */
- (void)assistedSetup
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar removeFromSuperview];
    
    // 设置自己的navBar
    self.myNavBar = [PPNavBar navBar];
    self.myNavBar.title = @"选择取货点";
    [self.myNavBar.leftBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.view addSubview:self.myNavBar];
    [self.myNavBar.rigntBtn addTarget:self action:@selector(shouMapView) forControlEvents:UIControlEventTouchUpInside];
    [self.myNavBar.leftBtn addTarget:self action:@selector(leftBtnBack) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  初始化引擎
 */
- (void)setupMapManager
{
    if (!_mapManager) {
        _mapManager = [[BMKMapManager alloc] init];
        BOOL ret = [_mapManager start:@"SGYQezd7y420cBN1Auj6KNlv" generalDelegate:nil];
        if (!ret) {
//            NSLog(@"百度地图引擎开启失败!");
        } else {
            [self setupMapView]; // 初始化地图
        }
    }
}

/**
 *  显示地图
 */
- (void)shouMapView
{
   CGRect showInfoViewRect = self.showInfoView.frame;
    showInfoViewRect.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.showInfoView.frame = showInfoViewRect;
        [self.myNavBar.rigntBtn setTitle:@"" forState:UIControlStateNormal];
    }];
}

/**
 *  返回按钮被点击
 */
- (void)leftBtnBack
{
    if ([self.delegate respondsToSelector:@selector(placePickerController:didFinishPickingPlace:)]) {
        [self.delegate placePickerController:self didFinishPickingPlace:self.placeDict];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  初始化搜索框
 */
- (void)setupSearchBar
{
    self.searchView = [[PPSearchView alloc] init];
    self.searchView.frame = CGRectMake(0, 64 - [[UIApplication sharedApplication] statusBarFrame ].size.height , self.view.bounds.size.width, 44 + [[UIApplication sharedApplication] statusBarFrame ].size.height);
    [self.view addSubview:self.searchView];
    [self.view insertSubview:self.searchView belowSubview:self.myNavBar];
    self.searchView.searchBar.delegate = self;
}

/**
 *  初始化地图
 */
- (void)setupMapView
{
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchView.frame), self.view.bounds.size.width, self.view.bounds.size.height - self.searchView.searchBar.bounds.size.height - 64)];
    self.mapView.mapType = BMKMapTypeStandard;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    [self.view addSubview:self.mapView];
}

/**
 *  显示信息View
 */
- (void)setupShowInfoView
{
    if (self.showInfoView == nil) {
        self.showInfoView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.searchView.frame))];
        self.showInfoView.delegate = self;
        self.showInfoView.dataSource = self;
        [self.view addSubview:self.showInfoView];
    }
}

/**
 *  初始化定位
 */
- (void)setupLocation
{
    // 开启定位服务
    self.locService = [[BMKLocationService alloc]init];
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation = NO;
}

/**
 *  设置商家地址位置
 */
- (void)setupStoreAddress:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    // 1.商家
    CLLocationCoordinate2D coor;
    coor.latitude = latitude;
    coor.longitude = longitude;
    if (self.storePointAnnotation == nil) {
        // 1.设定位置
        self.storePointAnnotation = [[BMKPointAnnotation alloc]init];
        self.storePointAnnotation.coordinate = coor;
        [_mapView addAnnotation:self.storePointAnnotation];
        
        // 3.添加商家覆盖物
        self.storeCircle = [BMKCircle circleWithCenterCoordinate:coor radius:2000];
        [_mapView addOverlay:self.storeCircle];
        self.storeWCircle = [BMKCircle circleWithCenterCoordinate:coor radius:9000];
        [_mapView addOverlay:self.storeWCircle];
    }
}

/**
 *  初始化检索
 */
- (void)setupSearch
{
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    self.poisearch = [[BMKPoiSearch alloc] init];
}

/**
 *  周边检索
 */
- (void)nearWithSearchText:(NSString *)searchText
{
    BMKPoiInfo *poiInfo = [self.poiList firstObject];
    if (poiInfo.city) {
        curPage = 0;
        //发起检索
        self.nearBySearchOption.pageIndex = curPage;
        self.nearBySearchOption.pageCapacity = 40;
        self.nearBySearchOption.location = poiInfo.pt;
        self.nearBySearchOption.keyword = searchText;
        BOOL flag = [_poisearch poiSearchNearBy:self.nearBySearchOption];
        if(flag)
        {
//            NSLog(@"周边检索发送成功");
        }
        else
        {  
//            NSLog(@"周边检索发送失败");  
        }
    } else {
//        NSLog(@"请重新选择地址");
    }
}

/**
 *  反geo请求
 */
- (void)requestReverseGeocode:(CLLocationCoordinate2D)coordinate
{
    self.reverseGeocodeSearchOption.reverseGeoPoint = coordinate; //设置反编码的位置经纬度
    BOOL flag = [self.geoCodeSearch reverseGeoCode:self.reverseGeocodeSearchOption];//发送反编码请求.并返回是否成功
    if(flag)
    {
//                NSLog(@"反geo检索发送成功");
    }
    else
    {
//                NSLog(@"反geo检索发送失败");
    }
}

#pragma mark - 地图代理方法
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    backType = PlacePickerViewControllerBackTypeBlank;
    clickCoordinate2D = coordinate; // 用于代理方法输出
    [self setupClickedMap:coordinate];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    backType = PlacePickerViewControllerBackTypePoi;
    clickCoordinate2D = mapPoi.pt; // 用于代理方法输出
    [self setupClickedMap:mapPoi.pt];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if (annotation == self.picUpCarPointAnnotation) { // 取车点大头针View
        NSString *picAnnotationViewID = @"picAnnotationViewID";
        self.picAnnotationView = (PPAnnotationView *)[self createAnnotationView:mapView andAnnotationViewID:picAnnotationViewID andAnnotation:annotation];
        self.picAnnotationView.image = [UIImage imageNamed:@"qucheIcon"];
       return self.picAnnotationView;
    } else if (annotation == self.storePointAnnotation) { // 商家大头针View
        NSString *storeAnnotationViewID = @"storeAnnotationViewID";
        PPAnnotationView *storeAnnotationView = (PPAnnotationView *)[self createAnnotationView:mapView andAnnotationViewID:storeAnnotationViewID andAnnotation:annotation];
        storeAnnotationView.image = [UIImage imageNamed:@"storeIcon"];
        storeAnnotationView.title = self.serviceInfo[@"serviceName"];
        storeAnnotationView.titleColor = [UIColor orangeColor];
        return storeAnnotationView;
    } else if(annotation == self.locationAnnotation){ // 定位View
        NSString *locationAnnotationViewID = @"locationAnnotationViewID";
        PPAnnotationView *locationAnnotationView = (PPAnnotationView *)[self createAnnotationView:mapView andAnnotationViewID:locationAnnotationViewID andAnnotation:annotation];
        locationAnnotationView.canShowCallout = NO;
        locationAnnotationView.image = [UIImage imageNamed:@"location"];
        locationAnnotationView.title = @"当前位置";
        locationAnnotationView.titleColor = [UIColor blueColor];
        return locationAnnotationView;
    } else { // 待选地址View
        NSString *screenAnnotationViewID = @"screenAnnotationViewID";
        PPAnnotationView *screenAnnotationView = (PPAnnotationView *)[self createAnnotationView:mapView andAnnotationViewID:screenAnnotationViewID andAnnotation:annotation];
        screenAnnotationView.canShowCallout = NO; // 如果Annotation的title没设，则canShowCallout为NO,如果Annotation的title有值，则canShowCallout为YES(这里是个坑，canShowCallout默认值为YES,否则会点不中view)
        screenAnnotationView.image = [UIImage imageNamed:@"storeIcon"];
        return screenAnnotationView;
    }
    return nil;
}

/**
 *  根据overlay生成对应的View(商家为中心外面的圈圈View)
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if (overlay == self.storeCircle) {
        BMKCircleView* storeCircleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        storeCircleView.fillColor = [UIColor colorWithRed:241/255.0 green:158/255.0 blue:194/255.0 alpha:0.3];
        storeCircleView.strokeColor = [UIColor colorWithRed:241/255.0 green:158/255.0 blue:194/255.0 alpha:0.0];
        storeCircleView.lineWidth = 0;
        return storeCircleView;
    }
    
    if (overlay == self.storeWCircle) {
        BMKCircleView* storeCircleWView = [[BMKCircleView alloc] initWithOverlay:overlay];
        storeCircleWView.fillColor = [UIColor colorWithRed:200/255.0 green:158/255.0 blue:194/255.0 alpha:0.3];
        storeCircleWView.strokeColor = [UIColor colorWithRed:200/255.0 green:158/255.0 blue:194/255.0 alpha:0.0];
        storeCircleWView.lineWidth = 0;
        return storeCircleWView;
    }

// 用于路径规划
//   	if ([overlay isKindOfClass:[BMKPolyline class]]) {
//        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
//        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
//        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
//        polylineView.lineWidth = 3.0;
//        return polylineView;
//    }
    
    return nil;
}

/**
 *  点击AnnotationView调用此代理方法
 *   注意点: 当Annotation的title没有设时，必须canShowCallout设为NO,否则调不了此代理方法
 *          默认情况下的canShowCallout为YES,这时必须要设置Annotation的title,否则也调不了这方法
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view isKindOfClass:[PPAnnotationView class]]) {
        [self setupClickedMap:view.annotation.coordinate];
    }
}

#pragma mark - 定位代理方法
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    // 0.设置定位点
    // 使用自己的定位(用annotaion实现)
    if (self.locationAnnotation == nil) {
        self.locationAnnotation = [[BMKPointAnnotation alloc] init];
        [self.mapView addAnnotation:self.locationAnnotation];
    }
    self.locationAnnotation.coordinate = userLocation.location.coordinate;
    
    // 1.设置商家地址位置
    [self setupStoreAddress:[self.serviceInfo[@"serviceLatitude"] doubleValue] andLongitude:[self.serviceInfo[@"serviceLongitude"] doubleValue]];
    
    // 2.添加定位点覆盖物做为默认取车点
    if (self.picUpCarPointAnnotation == nil) {
        self.picUpCarPointAnnotation = [[BMKPointAnnotation alloc]init];
        self.picUpCarPointAnnotation.coordinate = userLocation.location.coordinate;
        [_mapView addAnnotation:self.picUpCarPointAnnotation];
        
        // 设置显示经纬度范围
        BMKCoordinateRegion coordRegion;
        coordRegion.center = self.picUpCarPointAnnotation.coordinate;
        coordRegion.span.latitudeDelta = 0.08;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
        coordRegion.span.longitudeDelta = 0.08;//纬度范围
        [_mapView setRegion:coordRegion animated:YES];
        self.coordRegion = coordRegion;
        
        clickCoordinate2D = userLocation.location.coordinate; // 用于经纬度输出
        [self requestReverseGeocode:self.picUpCarPointAnnotation.coordinate]; // 反编码请求
    }
    
    [_mapView updateLocationData:userLocation];
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    switch (error.code) {
        case kCLErrorLocationUnknown: // 位置不明(百度定位识别不出来)
            break;
        case kCLErrorDenied: // 定位未开启
        {
            NSString *message = @"请在\"设置\"-\"隐私\"-\"定位服务\"中打开";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请开启定位" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case kCLErrorNetwork: // 网络有问题
        {
            NSLog(@"您家网络有问题了");
        }
            break;
        case kCLErrorHeadingFailure:
        {
            NSLog(@"标题无法确定");
        }
            break;
        case kCLErrorRegionMonitoringDenied:
        {
            NSLog(@"位置区域监控已被拒绝用户");
        }
            break;
        case kCLErrorRegionMonitoringFailure:
        {
            NSLog(@"已注册的区域不能被监视");
        }
            break;
        case kCLErrorRegionMonitoringSetupDelayed:
        {
            NSLog(@"CL无法立即初始化区域监控");
        }
            break;
        case kCLErrorRegionMonitoringResponseDelayed:
        {
            
        }
            break;
        case kCLErrorGeocodeFoundNoResult:
        {
            NSLog(@"地理编码请求没有产生任何结果");
        }
            break;
        case kCLErrorGeocodeFoundPartialResult:
        {
            NSLog(@"地理编码请求，产生了部分结果");
        }
            break;
        case kCLErrorGeocodeCanceled:
        {
            NSLog(@"KCL错误地理编码取消");
        }
            break;
        case kCLErrorDeferredFailed:
        {
            NSLog(@"Deferred模式失败");
        }
            break;
        case kCLErrorDeferredNotUpdatingLocation:
        {
            NSLog(@"Deferred模式失败,因为位置更新被禁用或暂停");
        }
            break;
        case kCLErrorDeferredAccuracyTooLow:
        {
            NSLog(@"不支持所请求的准确性延迟模式");
        }
            break;
        case kCLErrorDeferredDistanceFiltered:
        {
            NSLog(@"Deferred模式不支持距离过滤器");
        }
            break;
        case kCLErrorDeferredCanceled:
        {
            NSLog(@"Deferred模式请求取消以前的请求");
        }
            break;
        case kCLErrorRangingUnavailable:
        {
            NSLog(@"测距不能进行");
        }
            break;
        case kCLErrorRangingFailure:
        {
            NSLog(@"测距失败");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 检索代理方法
/**
 *  poi搜索结果
 */
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        self.poiList = poiResult.poiInfoList;
        [self.showInfoView reloadData];
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
//        NSLog(@"起始点有歧义");
    } else {
//        NSLog(@"抱歉，未找到结果");
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        self.poiList = result.poiList;
        [self.showInfoView reloadData];
        if (self.poiList.count) {
            BMKPoiInfo *poiInfo = [self.poiList firstObject];
            if (backType == PlacePickerViewControllerBackTypePoi) {
                [self respondsDelegateName:poiInfo.name andAddress:poiInfo.address]; // 通知代理
                self.myNavBar.title = poiInfo.name;
            } else {
                [self respondsDelegateName:nil andAddress:result.address];
                self.myNavBar.title = result.address;
            }
        } else {
            self.myNavBar.title = @"不明地址";
        }
    }
}

#pragma mark - tableView代理及数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"POILISTID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    BMKPoiInfo *poiInfo = self.poiList[indexPath.row];
    cell.textLabel.text = poiInfo.name;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = poiInfo.address;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMKPoiInfo *poiInfo = self.poiList[indexPath.row];
    self.picUpCarPointAnnotation.coordinate = poiInfo.pt;
    self.myNavBar.title = poiInfo.name;
    clickCoordinate2D = poiInfo.pt;
    [self respondsDelegateName:poiInfo.name andAddress:poiInfo.address];
    
    BMKCoordinateRegion coordRegion = self.coordRegion;
    coordRegion.center.latitude = poiInfo.pt.latitude;
    coordRegion.center.longitude = poiInfo.pt.longitude;
    coordRegion.span.latitudeDelta = 0.003;
    coordRegion.span.longitudeDelta = 0.003;
    self.coordRegion = coordRegion;
    [_mapView setRegion:coordRegion animated:YES];
    
    // 显示回地图及退回处理
    [self.searchView.searchBar resignFirstResponder];
    CGRect showInfoViewRect = self.showInfoView.frame;
    showInfoViewRect.origin.y = self.view.bounds.size.height;
    CGRect searchViewRect = self.searchView.frame;
    searchViewRect.origin.y = 64 - [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect navBarRect = self.myNavBar.frame;
    navBarRect.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.showInfoView.frame = showInfoViewRect;
        self.searchView.frame = searchViewRect;
        self.myNavBar.frame = navBarRect;
        [self.searchView.searchBar setShowsCancelButton:NO animated:YES];
    }];
    
    [self.myNavBar.rigntBtn setTitle:@"" forState:UIControlStateNormal];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchView.searchBar resignFirstResponder];
}

#pragma mark - searchBar代理方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.myNavBar.rigntBtn setTitle:@"" forState:UIControlStateNormal];
    // 设置navBar
    CGRect navBarFrame = self.myNavBar.frame;
    navBarFrame.origin.y = -navBarFrame.size.height;
    // 设置searchBar
    CGRect searchBarFrame = self.searchView.frame;
    searchBarFrame.origin.y = 0;
    // 设置显示信息View
    CGRect showInfoViewRect = self.showInfoView.frame;
    showInfoViewRect.origin.y = self.searchView.bounds.size.height;
    showInfoViewRect.size.height = self.view.bounds.size.height - self.searchView.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.myNavBar.frame = navBarFrame;
        self.searchView.frame = searchBarFrame;
        self.showInfoView.frame = showInfoViewRect;
         [searchBar setShowsCancelButton:YES animated:YES];
    }];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self nearWithSearchText:searchText]; // 周边检索
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
}

/**
 *  搜索框右边取消按钮被点击
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.myNavBar.rigntBtn setTitle:@"显示地图" forState:UIControlStateNormal];
    [searchBar resignFirstResponder];
    CGRect searchBarFrame = self.searchView.frame;
    searchBarFrame.origin.y = 64 - [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect navBarFrame = self.myNavBar.frame;
    navBarFrame.origin.y = 0;
    CGRect showInfoViewRect = self.showInfoView.frame;
    showInfoViewRect.origin.y = 64 + searchBar.bounds.size.height;
    showInfoViewRect.size.height = self.view.bounds.size.height - self.myNavBar.bounds.size.height - self.searchView.searchBar.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.searchView.frame = searchBarFrame;
        self.myNavBar.frame = navBarFrame;
        self.showInfoView.frame = showInfoViewRect;
        [searchBar setShowsCancelButton:NO animated:YES];
    }];
    self.searchView.frame = searchBarFrame;
}

#pragma mark - 私有方法
/**
 *  点击地图背景方法
 */
- (void)setupClickedMap:(CLLocationCoordinate2D)coordinate
{
    self.picUpCarPointAnnotation.coordinate = coordinate;
    [self requestReverseGeocode:self.picUpCarPointAnnotation.coordinate]; // 反编码请求
    [self.searchView.searchBar resignFirstResponder];
}

/**
 *  点与商家点的显示位置
 */
- (void)adjustPosition:(CLLocationCoordinate2D)coordinate
{
    CLLocationDegrees centerLatitude = (coordinate.latitude + self.storePointAnnotation.coordinate.latitude) * 0.5;
    CLLocationDegrees centerLongitude = (coordinate.longitude + self.storePointAnnotation.coordinate.longitude) * 0.5;
    
    CLLocationDegrees deltaLatitude = coordinate.latitude - self.storePointAnnotation.coordinate.latitude;
    CLLocationDegrees deltaLongitude = coordinate.longitude - self.storePointAnnotation.coordinate.longitude;
    if (deltaLatitude < 0) {
        deltaLatitude = -deltaLatitude;
    }
    
    if (deltaLongitude < 0) {
        deltaLongitude = -deltaLongitude;
    }
    
    BMKCoordinateRegion coordRegion = self.coordRegion;
    coordRegion.center.latitude = centerLatitude;
    coordRegion.center.longitude = centerLongitude;
    coordRegion.span.latitudeDelta = deltaLatitude * 1.5;
    coordRegion.span.longitudeDelta = deltaLongitude * 1.5;
    self.coordRegion = coordRegion;
    [_mapView setRegion:coordRegion animated:YES];
}

/**
 *  创建AnnotationView
 */
- (BMKAnnotationView *)createAnnotationView:(BMKMapView *)mapView andAnnotationViewID:(NSString *)AnnotationViewID andAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[PPAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((PPAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorRed;
        ((PPAnnotationView *)annotationView).animatesDrop = YES;
    }

    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    return annotationView;
}

/**
 *  设置返回代理的参数
 */
- (void)respondsDelegateName:(NSString *)name andAddress:(NSString *)address
{
    // 真实
    self.placeDict = @{@"placeName": name ? name : @"",
                            @"placeAddress": address ? address : @"",
                            @"placeLongitude": @(clickCoordinate2D.longitude),
                            @"placeLatitude": @(clickCoordinate2D.latitude)};
    
//    [self adjustPosition:clickCoordinate2D];
//    [self routeSearch:clickCoordinate2D]; // 调用路径规划
//    NSLog(@"place:%@, placeName:%@, placeAddress:%@", place, place[@"placeName"], place[@"placeAddress"]);
    
//    // 测试
//    self.placeDict = @{@"placeName":@"黄岩检测站椒江分站（仅限蓝牌车）",
//                            @"placeAddress":@"台州市疏港大道椒江段2250号3幢一楼",
//                            @"placeLongitude":@"121.463111",
//                            @"placeLatitude":@"28.641178"};
}

//#pragma mark - 路径规划部分
//- (void)routeSearch:(CLLocationCoordinate2D)coordinate2D
//{
//    BMKRouteSearch *routesearch = [[BMKRouteSearch alloc] init];
//    routesearch.delegate = self;
//    BMKPlanNode* start = [[BMKPlanNode alloc]init];
//    start.pt = self.storePointAnnotation.coordinate;
//    BMKPlanNode* end = [[BMKPlanNode alloc]init];
//    end.pt = coordinate2D;
//    self.routePlanOption.from = start;
//    self.routePlanOption.to = end;
//    self.routePlanOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
//    BOOL flag =  [routesearch drivingSearch:self.routePlanOption];
//    if(flag)
//    {
//        NSLog(@"search success.");
//    }
//    else
//    {
//        NSLog(@"search failed!");
//    }
//}
//
///**
// *返回驾乘搜索结果
// *@param searcher 搜索对象
// *@param result 搜索结果，类型为BMKDrivingRouteResult
// *@param error 错误号，@see BMKSearchErrorCode
// */
//- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
//{
//    [self.mapView removeAnnotations:self.routePointArray];
//    
//    NSMutableArray *polylines = [NSMutableArray array];
//    for (id over in self.mapView.overlays) {
//        if ([over isKindOfClass:[BMKPolyline class]]) {
//            [polylines addObject:over];
//        }
//    }
//    self.routePointArray = [NSMutableArray arrayWithArray:polylines];
//    [self.mapView removeOverlays:self.routePointArray];
//    self.routePointArray = nil;
//    
//    if (error == BMK_SEARCH_NO_ERROR) {
//        BMKDrivingRouteLine *plan = (BMKDrivingRouteLine*)result.routes[0];
////        NSLog(@"distance:%d", plan.distance);
//        // 计算路线方案中的路段数目
//        int planPointCounts = 0;
//        for (int i = 0; i < plan.steps.count; i++) {
//            BMKDrivingStep* transitStep = plan.steps[i];
////            //添加annotation节点
//            BMKPointAnnotation *item = [[BMKPointAnnotation alloc]init];
//            item.coordinate = transitStep.entrace.location;
//            item.title = transitStep.entraceInstruction;
//            [_mapView addAnnotation:item];
////            //轨迹点总数累计
//            planPointCounts += transitStep.pointsCount;
//            [self.routePointArray addObject:item];
//        }
//        // 添加途经点
//        if (plan.wayPoints) {
//            for (BMKPlanNode* tempNode in plan.wayPoints) {
//                BMKPointAnnotation *item = [[BMKPointAnnotation alloc]init];
//                item = [[BMKPointAnnotation alloc]init];
//                item.coordinate = tempNode.pt;
//                item.title = tempNode.name;
//                [_mapView addAnnotation:item];
//            }
//        }
////        //轨迹点
//        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
//        int i = 0;
//        for (int j = 0; j < plan.steps.count; j++) {
//            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
//            int k=0;
//            for(k=0;k<transitStep.pointsCount;k++) {
//                temppoints[i].x = transitStep.points[k].x;
//                temppoints[i].y = transitStep.points[k].y;
//                i++;
//            }
//        }
////        // 通过points构建BMKPolyline
//        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
//        [_mapView addOverlay:polyLine]; // 添加路线overlay
//        delete []temppoints;
//        [self mapViewFitPolyLine:polyLine];
//    }
//    
//
//}
//
////根据polyline设置地图范围
//- (void)mapViewFitPolyLine:(BMKPolyline *)polyLine {
//    CGFloat ltX, ltY, rbX, rbY;
//    if (polyLine.pointCount < 1) {
//        return;
//    }
//    BMKMapPoint pt = polyLine.points[0];
//    ltX = pt.x, ltY = pt.y;
//    rbX = pt.x, rbY = pt.y;
//    for (int i = 1; i < polyLine.pointCount; i++) {
//        BMKMapPoint pt = polyLine.points[i];
//        if (pt.x < ltX) {
//            ltX = pt.x;
//        }
//        if (pt.x > rbX) {
//            rbX = pt.x;
//        }
//        if (pt.y > ltY) {
//            ltY = pt.y;
//        }
//        if (pt.y < rbY) {
//            rbY = pt.y;
//        }
//    }
//    BMKMapRect rect;
//    rect.origin = BMKMapPointMake(ltX , ltY);
//    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
//    [_mapView setVisibleMapRect:rect];
//    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
//}
//
#pragma mark - 释放
- (void)dealloc {
    if (self.locService != nil) {
        self.locService = nil;
    }
    
    if (self.poisearch != nil) {
        self.poisearch = nil;
    }
    
    if (self.geoCodeSearch != nil) {
        self.geoCodeSearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}


@end









