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

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cityLabel.text = nil;
    NSDictionary *userlocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    double longitude = [[userlocation objectForKey:@"longitude"] doubleValue];
    double latitude = [[userlocation objectForKey:@"latitude"] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.cityLabel.text = [NSString stringWithFormat:@"%@ - %@", placemark.locality, placemark.subLocality];
    }];
}

- (IBAction)toMenu01:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=130401&title=%E6%9C%BA%E6%B2%B9"]];
}

- (IBAction)toMenu02:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=130200&title=%E6%BB%A4%E6%B8%85%E5%99%A8"]];
}

- (IBAction)toMenu03:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=180200&title=%E8%BD%AE%E8%83%8E"]];
}

- (IBAction)toMenu04:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270420&title=%E9%9B%A8%E5%88%AE%E7%89%87"]];
}

- (IBAction)toMenu05:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=191100&title=%E7%94%B5%E7%93%B6"]];
}

- (IBAction)toMenu06:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=110100&title=%E7%81%AB%E8%8A%B1%E5%A1%9E"]];
}

- (IBAction)toMenu07:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170700&title=%E5%88%B9%E8%BD%A6%E7%89%87"]];
}

- (IBAction)toMenu08:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170500&title=%E5%88%B9%E8%BD%A6%E7%9B%98"]];
}

- (IBAction)toMenu09:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=190300&title=%E8%BD%A6%E7%81%AF"]];
}

- (IBAction)toMenu10:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220200&title=%E8%BD%A6%E8%BA%AB%E4%BB%B6"]];
}

- (IBAction)toMenu11:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=220100&title=%E9%92%A3%E9%87%91%E4%BB%B6"]];
}

- (IBAction)toMenu12:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270400&title=%E6%94%B9%E8%A3%85%E4%BB%B6"]];
}

- (IBAction)toMenu13:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=100300&title=%E5%BA%95%E7%9B%98%E4%BB%B6"]];
}

- (IBAction)toMenu14:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=250400&title=%E8%BE%85%E6%96%99"]];
}

- (IBAction)toMenu15:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @""]];
}

- (IBAction)toMenu16:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @""]];
}

- (IBAction)toMenu17:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @""]];
}

- (IBAction)toMenu18:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @""]];
}

- (IBAction)toMenu19:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @""]];
}

- (void)launchWebViewWithURLString:(NSString *)URLString {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:URLString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
    [self close:nil];
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

- (IBAction)changeCity:(id)sender {
    NSLog(@"changeCity");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
