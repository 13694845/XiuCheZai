//
//  AppDelegate.m
//  XiuCheZai
//
//  Created by QSH on 15/12/2.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "CachingURLProtocol.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle = UIStatusBarStyleLightContent;
    application.statusBarHidden = NO;
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
    [application registerForRemoteNotifications];
    // [NSURLProtocol registerClass:[CachingURLProtocol class]];
    [WXApi registerApp:@"wx6f70675b8950f10e" withDescription:nil];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapManager = [[BMKMapManager alloc] init];
    [self.mapManager start:@"SGYQezd7y420cBN1Auj6KNlv" generalDelegate:nil];
    self.chatService = [[ChatService alloc] init];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {}];
    [WXApi handleOpenURL:url delegate:self.wxApiDelegate];
    return YES;
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
    [self.chatService start];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = locations.firstObject;
    NSMutableDictionary *userlocation = [NSMutableDictionary dictionary];
    [userlocation setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [userlocation setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:userlocation forKey:@"userLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // [self.chatService stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {}

@end
