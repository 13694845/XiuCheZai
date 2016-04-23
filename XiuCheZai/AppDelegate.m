//
//  AppDelegate.m
//  XiuCheZai
//
//  Created by QSH on 15/12/2.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
// #import "CachingURLProtocol.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle = UIStatusBarStyleLightContent;
    application.statusBarHidden = NO;
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
                                                                                                UIUserNotificationTypeSound |
                                                                                                UIUserNotificationTypeAlert) categories:nil]];
    [application registerForRemoteNotifications];
    // [NSURLProtocol registerClass:[CachingURLProtocol class]];
    [WXApi registerApp:@"wx6f70675b8950f10e" withDescription:nil];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {}];
    [WXApi handleOpenURL:url delegate:self.wxApiDelegate];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation]; break;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization]; break;
        case kCLAuthorizationStatusDenied: break;
        default: break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = locations.firstObject;
    NSMutableDictionary *userlocation = [NSMutableDictionary dictionary];
    [userlocation setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [userlocation setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:userlocation forKey:@"userLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
