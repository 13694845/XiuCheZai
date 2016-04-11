//
//  GoodsDetailViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/21.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "Config.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface GoodsDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *images;

@end

@implementation GoodsDetailViewController

- (NSMutableArray *)images {
    if (!_images) _images = [NSMutableArray array];
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@/%@", [manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/GoodsPrice.do"];
    NSDictionary *parameters = @{@"goods_id":self.goodsId};
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *remark = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"remark"];
        NSArray *imageSubstrings = [remark componentsSeparatedByString:@"＞＜"];
        NSMutableArray *imageUrls = [NSMutableArray array];
        for (int i = 0; i < imageSubstrings.count; i++) {
            NSString *imageUrlString = imageSubstrings[i];
            if ([imageUrlString rangeOfString:@"http://"].location == NSNotFound) continue;
            imageUrlString = [imageUrlString substringFromIndex:[imageUrlString rangeOfString:@"http://"].location];
            if ([imageUrlString rangeOfString:@"http://"].location == NSNotFound) continue;
            imageUrlString = [imageUrlString substringToIndex:[imageUrlString rangeOfString:@"#quot; alt#3D;"].location];
            [imageUrls addObject:imageUrlString];
        }
        [self loadImages:imageUrls];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = @"商品详情";
}

- (void)loadImages:(NSArray *)imageUrls {
    for (int i = 0; i < imageUrls.count; i++) {
        [self.images addObject:[UIImage imageNamed:@"common_blank.png"]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrls[i]]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [self.images replaceObjectAtIndex:i withObject:image];
                                [self.tableView reloadData];
                            }];
        [self.view addSubview:imageView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.images[indexPath.row];
    return tableView.frame.size.width / (image.size.width / image.size.height);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    imageView.image = self.images[indexPath.row];
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
