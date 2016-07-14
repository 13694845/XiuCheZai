//
//  BrandSelectorViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "BrandSelectorViewController.h"
#import "BrandSelectorCell.h"
#import "Config.h"
#import "AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface BrandSelectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSMutableArray *brands;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BrandSelectorViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSMutableArray *)brands {
    if (!_brands) _brands = [NSMutableArray array];
    return _brands;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadData];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoadCarBrandData.do"];
    NSDictionary *parameters = @{@"type":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *data = responseObject[@"data"];
        for (char i = 'A'; i <= 'Z'; i++) {
            NSArray *brands = [data objectForKey:[NSString stringWithFormat:@"%c", i]];
            for (NSDictionary *brand in brands) {
                [self.brands addObject:brand];
            }
        }
        NSLog(@"brands : %@", self.brands);
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.brands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSString *const kImageSize = @"30x30";
    
    BrandSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *imagePath = [self.brands[indexPath.row] objectForKey:@"brand_logo"];
    NSString *imageURLString = [NSString stringWithFormat:@"%@/%@_%@.%@", [Config imgBaseURL], imagePath.stringByDeletingPathExtension, kImageSize, imagePath.pathExtension];
     */
    BrandSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *imageURLString = [NSString stringWithFormat:@"%@/%@", [Config imgBaseURL], [self.brands[indexPath.row] objectForKey:@"brand_logo"]];
    [cell.brandLogoImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *brand = self.brands[indexPath.row];
    NSLog(@"brand : %@", brand);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
