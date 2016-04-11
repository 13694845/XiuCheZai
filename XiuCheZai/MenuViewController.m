//
//  MenuViewController.m
//  XiuCheZai
//
//  Created by QSH on 15/12/29.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "MenuViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WebViewController.h"
#import "Config.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *userlocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"userlocation"];
    double longitude = [[userlocation objectForKey:@"longitude"] doubleValue];
    double latitude = [[userlocation objectForKey:@"latitude"] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.cityLabel.text = placemark.subLocality;
    }];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
    [self close:nil];
}

- (IBAction)toMenu01:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220201&title=%E4%BF%9D%E9%99%A9%E6%9D%A0"]];
}

- (IBAction)toMenu02:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220205&title=%E4%B8%AD%E7%BD%91"]];
}

- (IBAction)toMenu03:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220102&title=%E5%8F%91%E5%8A%A8%E6%9C%BA%E7%9B%96"]];
}

- (IBAction)toMenu04:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=190302&title=%E5%A4%A7%E7%81%AF"]];
}

- (IBAction)toMenu05:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=190310&title=%E5%B0%BE%E7%81%AF"]];
}

- (IBAction)toMenu06:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=190304&title=%E9%9B%BE%E7%81%AF"]];
}

- (IBAction)toMenu07:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170700&title=%E5%88%B9%E8%BD%A6%E7%89%87"]];
}

- (IBAction)toMenu08:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170500&title=%E5%88%B6%E5%8A%A8%E7%9B%98"]];
}

- (IBAction)toMenu09:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=110100&title=%E7%81%AB%E8%8A%B1%E5%A1%9E"]];
}

- (IBAction)toMenu10:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=180100&title=%E9%92%A2%E5%9C%88"]];
}

- (IBAction)toMenu11:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=180200&title=%E8%BD%AE%E8%83%8E"]];
}

- (IBAction)toMenu12:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=130200&title=%E6%9C%BA%E6%B2%B9%E6%BB%A4%E8%8A%AF"]];
}

- (IBAction)toMenu13:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=100601&title=%E7%A9%BA%E6%B0%94%E6%BB%A4%E8%8A%AF"]];
}

- (IBAction)toMenu14:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=241700&title=%E8%A1%8C%E6%9D%8E%E6%9E%B6"]];
}

- (IBAction)toMenu15:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220204&title=%E9%97%A8%E8%BE%B9%E8%B8%8F%E6%9D%BF"]];
}

- (IBAction)toMenu16:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220101&title=%E8%BD%A6%E6%9E%B6%E6%80%BB%E6%88%90"]];
}

- (IBAction)toMenu17:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220206&title=%E5%B0%BE%E7%BF%BC"]];
}

- (IBAction)toMenu18:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220103&title=%E5%90%8E%E5%A4%87%E7%AE%B1%E7%9B%96"]];
}

- (IBAction)toMenu19:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220105&title=%E5%8F%B6%E5%AD%90%E6%9D%BF"]];
}

- (IBAction)close:(id)sender {
    CGRect rect = self.view.frame;
    rect.origin.x -= rect.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
