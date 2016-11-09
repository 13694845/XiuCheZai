//
//  XCZMessagePraiseViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessagePraiseViewController.h"
#import "XCZMessagePraiseViewCell.h"
#import "XCZMessageTopicDetailsViewController.h"
#import "XCZConfig.h"
#import "XCZPersonInfoViewController.h"
#import "XCZCircleDetailViewController.h"

@interface XCZMessagePraiseViewController () <UITableViewDataSource, UITableViewDelegate, XCZMessagePraiseViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) NSDictionary *artDict;
@property (assign, nonatomic) int currentPage;

@end

@implementation XCZMessagePraiseViewController

@synthesize rows = _rows;

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    [self jumpToDetailsVC];
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"赞我的";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsMessageAction.do"];
    NSDictionary *parameters = @{@"type":@"2"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
//
    /*
     URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/banner.do"];
     parameters = nil;
     [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
     self.banner = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
     } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
     */
    
}

- (void)requestCircleDetailVCNet:(NSString *)post_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0] , @"post_id":post_id};
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *datas = [responseObject objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]]) {
            datas = nil;
        }
        for (NSDictionary *dict in datas) {
            int taskId = [[dict objectForKey:@"taskId"] intValue];
            if (taskId == 2644) {
                self.artDict = [[dict objectForKey:@"rows"] firstObject];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}


- (void)updateTableView {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZMessagePraiseViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.row = self.rows[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - XCZMessagePraiseViewCellDelegate
- (void)praiseViewCell:(XCZMessagePraiseViewCell *)praiseViewCell brandsViewDidClick:(NSDictionary *)row
{
    XCZPersonInfoViewController *personInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoViewController.bbs_user_id = row[@"user_id"];
    [self.navigationController pushViewController:personInfoViewController animated:YES];
}

- (void)praiseViewCell:(XCZMessagePraiseViewCell *)praiseViewCell praiseViewDidClick:(NSDictionary *)row
{
    [self requestCircleDetailVCNet:row[@"posts_id"]];
}

#pragma mark - 跳转控制器
- (void)jumpToDetailsVC
{
    int post_clazz = [_artDict[@"post_clazz"] intValue];
    NSString *share_image = _artDict[@"share_image"];
    NSString *identifier;
    if (post_clazz == 1) {
        identifier = @"CellWZ";
    } else if (post_clazz == 2) { // 投票贴，暂时没有
        identifier = @"CellWZ";
    } else if (post_clazz == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:share_image andImageArray:imageArray];
        if (imageArray.count == 1) {
            identifier = @"CellB";
        } else if (imageArray.count <= 3) {
            identifier = @"CellA1";
        } else if (imageArray.count <= 6) {
            identifier = @"CellA";
        } else {
            identifier = @"CellA2";
        }
    } else if (post_clazz == 4) {
        NSMutableArray *imageArray = [NSMutableArray array];
        if (!((NSString *)share_image).length) {
            identifier = @"CellC1";
        } else {
            imageArray = [self changeImage:share_image andImageArray:imageArray];
            if (imageArray.count == 0) {
                identifier = @"CellC1";
            } else if (imageArray.count <= 3) {
                identifier = @"CellC";
            } else if (imageArray.count <= 6) {
                identifier = @"CellC2";
            } else {
                identifier = @"CellC3";
            }
        }
    }
    
    XCZCircleDetailViewController *topicDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    topicDetailsVC.reuseIdentifier = identifier;
    topicDetailsVC.post_id = _artDict[@"post_id"];
    [self.navigationController pushViewController:topicDetailsVC animated:YES];
}

/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [imageArray addObject:[imageStrs substringToIndex:range.location]];
        [self changeImage:[imageStrs substringFromIndex:(range.location + 1)] andImageArray:imageArray];
    } else {
        [imageArray addObject:imageStrs];
    }
    return imageArray;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
