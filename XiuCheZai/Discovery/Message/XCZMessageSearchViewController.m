//
//  XCZMessageSearchViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/31.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSearchViewController.h"
#import "XCZMessageSearchDefaultView.h"
#import "XCZConfig.h"
#import "XCZMessageSearchResultClubCell.h"
#import "XCZMessageSearchResultTopicCell.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZClubCircleViewController.h"
#import "XCZCircleDetailViewController.h"

@interface XCZMessageSearchViewController()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *forum;
@property (nonatomic, strong) NSMutableArray *post;
@property (nonatomic, weak) XCZMessageSearchDefaultView *defaultView;
@property (nonatomic, weak) UITableView *tableView;
@property (assign, nonatomic) int currentForumPage;
@property (assign, nonatomic) int currentPostPage;

@property (nonatomic, strong) NSArray *banners;
@property (assign, nonatomic) NSInteger sectionOneRow;
@property (assign, nonatomic) NSInteger sectionTwoRow;

@end

@implementation XCZMessageSearchViewController

@synthesize searchResults = _searchResults;
@synthesize forum = _forum;
@synthesize post = _post;
@synthesize banners = _banners;

- (void)setSearchResults:(NSArray *)searchResults
{
    _searchResults = searchResults;
    
    [self.defaultView removeFromSuperview];
    self.defaultView = nil;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)setForum:(NSMutableArray *)forum
{
    _forum = forum;
    
    self.currentForumPage++;
    if (self.currentForumPage >= 3) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)setPost:(NSMutableArray *)post
{
    _post = post;
    self.currentPostPage++;
    if (self.currentPostPage >= 3) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)setBanners:(NSArray *)banners
{
    _banners = banners;
    
    int same = 0;
    for (NSDictionary *dict in banners) {
        if ([[dict objectForKey:@"forum_id"] isEqualToString:self.forum[self.sectionOneRow][@"forum_id"]]) {
            same++;
        }
    }
    XCZClubCircleViewController *circleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleViewController"];
    circleVC.hasJoin = same ? YES : NO ;
    circleVC.forum_id = self.forum[self.sectionOneRow][@"forum_id"];
    [self.navigationController pushViewController:circleVC animated:YES];
}

- (NSMutableArray *)forum
{
    if (!_forum) {
        _forum = [NSMutableArray array];
    }
    return _forum;
}

- (NSMutableArray *)post
{
    if (!_post) {
        _post = [NSMutableArray array];
    }
    return _post;
}

- (NSArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSArray array];
    }
    return _searchResults;
}

- (NSArray *)banners
{
    if (!_banners) {
        _banners = [NSArray array];
    }
    return _banners;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar setBackgroundImage:[UIImage new]]; // 去除黑线
    self.searchBar.delegate = self;
    [self createDefaultView];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)createDefaultView
{
    XCZMessageSearchDefaultView *defaultView = [[XCZMessageSearchDefaultView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    defaultView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:defaultView];
    self.defaultView = defaultView;
}

- (void)refreshData:(NSString *)type
{
    if ([type isEqualToString:@"1"]) {
        self.currentForumPage = 1;
        self.currentPostPage = 1;
    }
    [self requestSearchNet:type];
}

- (void)cancelBtnDidClick
{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sectionFooterViewDidClick:(UIGestureRecognizer *)grz
{
    [self.searchBar resignFirstResponder];
    if (!grz.view.tag) {
        [self refreshData:@"2"];
    } else {
        [self refreshData:@"3"];
    }
}

#pragma mark - 网络请求
- (void)requestSearchNet:(NSString *)type
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsQueryAction.do"];
    NSDictionary *parameters;
    if ([type isEqualToString:@"1"]) {
        parameters  = @{@"type":type, @"forum_name": self.searchBar.text};
    } else if([type isEqualToString:@"2"]) {
        parameters = @{@"type":type, @"forum_name": self.searchBar.text, @"page": [NSString stringWithFormat:@"%d", self.currentForumPage], @"size": @"3"};
    } else if([type isEqualToString:@"3"]) {
        parameters = @{@"type":type, @"forum_name": self.searchBar.text, @"page": [NSString stringWithFormat:@"%d", self.currentPostPage], @"size": @"3"};
    }
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([type isEqualToString:@"1"]) {
            NSMutableArray *searchResultArray = [NSMutableArray array];
            NSArray *forum = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"forum"];
            NSArray *post = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"post"];
            [searchResultArray addObject:forum];
            [searchResultArray addObject:post];
            self.searchResults = searchResultArray;
            self.forum = [forum mutableCopy];
            self.post = [post mutableCopy];
        } else if([type isEqualToString:@"2"]) {
            NSArray *rows = [[[[responseObject objectForKey:@"data"] objectForKey:@"data"] firstObject] objectForKey:@"rows"];
            if (rows.count) {
                self.forum = [[self.forum arrayByAddingObjectsFromArray:rows] mutableCopy];
            } else {
                [MBProgressHUD ZHMShowError:@"暂无更多相关车友会"];
            }
        } else if([type isEqualToString:@"3"]) {
            NSArray *rows = [[[[responseObject objectForKey:@"data"] objectForKey:@"data"] firstObject] objectForKey:@"rows"];
            if (rows.count) {
                self.post = [[self.post arrayByAddingObjectsFromArray:rows] mutableCopy];
            } else {
                [MBProgressHUD ZHMShowError:@"暂无更多相关话题"];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)requestHeaderViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":@"0"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"msgmsgmsg:%@", responseObject[@"msg"]);
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"未登录"]) {
        } else { // 已登录
            self.banners = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length) {
        [self refreshData:@"1"];
    } else {
        [self.tableView removeFromSuperview];
        self.tableView = nil;
        [self createDefaultView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    if (searchBar.text.length) {
        [self refreshData:@"1"];
    } else {
        [self.tableView removeFromSuperview];
        self.tableView = nil;
        [self createDefaultView];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? self.post.count : self.forum.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *identifier = @"clubCell";
        XCZMessageSearchResultClubCell *clubCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!clubCell) {
            clubCell = [[XCZMessageSearchResultClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        clubCell.selfW = self.tableView.bounds.size.width;
        clubCell.row = self.forum[indexPath.row];
        return clubCell;
    } else {
        static NSString *identifier = @"topicCell";
        XCZMessageSearchResultTopicCell *topicCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!topicCell) {
            topicCell = [[XCZMessageSearchResultTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        topicCell.selfW = self.tableView.bounds.size.width;
        topicCell.row = self.post[indexPath.row];
        return topicCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] init];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0.5, self.tableView.bounds.size.width - 24, 37)];
    textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.text = section ? @"话题" : @"车友会";
    [sectionHeaderView addSubview:textLabel];
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37.5, self.tableView.bounds.size.width, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [sectionHeaderView addSubview:bottomLineView];
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] init];
    sectionFooterView.tag = section;
    sectionFooterView.backgroundColor = [UIColor whiteColor];
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0.5)];
    topLineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [sectionFooterView addSubview:topLineView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0.5, self.tableView.bounds.size.width - 24, 37)];
    textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.text = section ? @"查看更多话题" : @"查看更多车友会";
    [sectionFooterView addSubview:textLabel];
    
    CGFloat rightArrowViewW = 5.5;
    CGFloat rightArrowViewH = 10;
    CGFloat rightArrowViewX = self.tableView.bounds.size.width - 16 - rightArrowViewW;
    CGFloat rightArrowViewY = (38 - rightArrowViewH) * 0.5;
    UIImageView *rightArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(rightArrowViewX, rightArrowViewY, rightArrowViewW, rightArrowViewH)];
    rightArrowView.image = [UIImage imageNamed:@"bbs_rightArrow"];
    [sectionFooterView addSubview:rightArrowView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37.5, self.tableView.bounds.size.width, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [sectionFooterView addSubview:bottomLineView];
    
    [sectionFooterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionFooterViewDidClick:)]];
    return sectionFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section ? 58 : 59;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 38;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        self.sectionOneRow = indexPath.row;
        [self requestHeaderViewNet];
    } else if (indexPath.section == 1) {
        self.sectionTwoRow = indexPath.row;
        
        XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
        circleDetailVC.reuseIdentifier = @"CellC";
        circleDetailVC.post_id =  [self.post[indexPath.row] objectForKey:@"post_id"];
        [self.navigationController pushViewController:circleDetailVC animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


@end
