//
//  SeriesSelectorViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "SeriesSelectorViewController.h"
#import "Config.h"
#import "AFNetworking.h"

@interface SeriesSelectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSMutableArray *series;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SeriesSelectorViewController


- (void)setHidden:(BOOL)hidden {
    NSLog(@"nav height : %f", self.navigationController.navigationBar.bounds.size.height);
}

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSMutableArray *)series {
    if (!_series) _series = [NSMutableArray array];
    return _series;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if (self.brandId) [self loadData];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoadCarBrandData.do"];
    NSDictionary *parameters = @{@"type":@"2", @"id":self.brandId};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.series = responseObject[@"data"];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.series.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     NSString *const kImageSize = @"30x30";
     
     BrandSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
     NSString *imagePath = [self.brands[indexPath.row] objectForKey:@"brand_logo"];
     NSString *imageURLString = [NSString stringWithFormat:@"%@/%@_%@.%@", [Config imgBaseURL], imagePath.stringByDeletingPathExtension, kImageSize, imagePath.pathExtension];
     */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.series[indexPath.row] objectForKey:@"car_model_name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSDictionary *brand = self.brands[indexPath.row];
    NSLog(@"brand : %@", brand);
    
    if (!self.childViewControllers.count) {
        SeriesSelectorViewController *seriesSelectorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesSelectorViewController"];
        seriesSelectorViewController.brandId = brand[@"brand_id"];
        seriesSelectorViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self addChildViewController:seriesSelectorViewController];
        
        CGRect rect = seriesSelectorViewController.view.frame;
        rect.origin.x += rect.size.width;
        rect.size.height = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.bounds.size.height;
        seriesSelectorViewController.view.frame = rect;
        
        [self.view addSubview:seriesSelectorViewController.view];
        rect.origin.x = 100;
        [UIView animateWithDuration:0.3 animations:^{
            seriesSelectorViewController.view.frame = rect;
        }];
    }
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
