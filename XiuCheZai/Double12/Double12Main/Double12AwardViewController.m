//
//  Double12AwardViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/11/24.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "Double12AwardViewController.h"
#import "Double12AwardViewCell.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "XCZDouble12WebViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZShareChannelPickerView.h"
#import "WXApi.h"
#define Double12HomeViewControllerShareId @"2"

#define kDevice_Is_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),  [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

@interface Double12AwardViewController ()<UITableViewDataSource, UITableViewDelegate, XCZShareChannelPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *topBackImageView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIImageView *bottomImageView;
@property (strong, nonatomic) UIButton *lookMyPacketBtn;
@property (strong, nonatomic) UIView *jiluView;
@property (strong, nonatomic) UILabel *jiluZiLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *priceUnitLabel;
@property (strong, nonatomic) UILabel *receiveSucessLabel;
@property (strong, nonatomic) UILabel *deseyxLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *tableFooterLabel;
@property (strong, nonatomic) UIButton *shareBtn;
@property (strong, nonatomic) UIButton *chaihongbaoBtn;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) NSMutableArray *xRecords;
@property (nonatomic, strong) NSArray *shareRows;
@property (strong, nonatomic) NSDictionary *shareDict;
@property (weak, nonatomic) UIView *coverView;
@property (weak, nonatomic) XCZShareChannelPickerView *shareChannelPickerView;
@property (assign, nonatomic) int currentPage;


@end

@implementation Double12AwardViewController

@synthesize info = _info;
@synthesize records = _records;
@synthesize xRecords = _xRecords;
@synthesize shareDict = _shareDict;

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [XCZConfig version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSArray *)shareRows
{
    if (!_shareRows) {
        _shareRows = @[
                       @{
                           @"name" : @"微信",
                           @"ShareMessageChannel": @"ShareMessageChannelWeixinSession",
                           @"icon" : @"bbs_weixinshare"
                           },
                       @{
                           @"name" : @"朋友圈",
                           @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                           @"icon" : @"bbs_pengyouquanshare"
                           },
                       //                          @{
                       //                              @"name" : @"新浪微博",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_xinlangshare"
                       //                              },
                       //                          @{
                       //                              @"name" : @"QQ好友",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_qqshare"
                       //                              },
                       //                          @{
                       //                              @"name" : @"QQ空间",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_qqsharekongjianshare"
                       //                              },
                       ];
    }
    return _shareRows;
}


- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], info[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    self.nameLabel.text = info[@"login_name"];
}

- (void)setXRecords:(NSMutableArray *)xRecords
{
    _xRecords = xRecords;
    
    if (self.records) {
        self.currentPage = 1;
    } else {
        self.currentPage++;
        [self.tableView reloadData];
    }
}

- (void)setRecords:(NSArray *)records
{
    _records = [records copy];
    
    self.currentPage = 1;
    self.xRecords = [records mutableCopy];
}

- (NSDictionary *)info
{
    if (!_info) {
        _info = [NSDictionary dictionary];
    }
    return _info;
}

- (NSMutableArray *)xRecords
{
    if (!_xRecords) {
        _xRecords = [NSMutableArray array];
    }
    return _xRecords;
}

- (void)setShareDict:(NSDictionary *)shareDict
{
    _shareDict = shareDict;
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    coverView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:coverView];
    self.coverView = coverView;
    
    XCZShareChannelPickerView *shareChannelPickerView = [[XCZShareChannelPickerView alloc] init];
    shareChannelPickerView.delegate = self;
    shareChannelPickerView.selfW = self.view.bounds.size.width;
    shareChannelPickerView.shareRows = self.shareRows;
    CGFloat shareChannelPickerViewH = shareChannelPickerView.bounds.size.height;
    shareChannelPickerView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, shareChannelPickerViewH);
    [self.view addSubview:shareChannelPickerView];
    
    self.shareChannelPickerView = shareChannelPickerView;
    CGRect shareChannelPickerViewRect = shareChannelPickerView.frame;
    shareChannelPickerViewRect.origin.y = self.view.bounds.size.height - shareChannelPickerViewH;
    [UIView animateWithDuration:0.3 animations:^{
        shareChannelPickerView.frame = shareChannelPickerViewRect;
    }];
    
    [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewDidClick:)]];
    
}

- (NSDictionary *)shareDict
{
    if (!_shareDict) {
        _shareDict = [NSDictionary dictionary];
    }
    return _shareDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 44)];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 16, 7, 12)];
    backImageView.image = [UIImage imageNamed:@"bbs_arrow"];
    [backBtn addSubview:backImageView];
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backImageView.frame) + 8, 16, backBtn.bounds.size.width - CGRectGetMaxX(backImageView.frame) + 8, 12)];
    backLabel.text = @"返回";
    backLabel.textColor = [UIColor whiteColor];
    backLabel.font = [UIFont systemFontOfSize:14];
    [backBtn addSubview:backLabel];
    [self.view addSubview:backBtn];
    
    if (self.type == Double12AwardViewControllerHasRecord) {
        [self setupShareBtn];
    }
    
    CGFloat iconViewW = (100/720.0) * self.view.bounds.size.height;
    CGFloat iconViewH = iconViewW;
    CGFloat iconViewX = (self.view.bounds.size.width - iconViewW) * 0.5;
    CGFloat iconViewY = self.view.bounds.size.width * (53/125.0) - iconViewH * 0.57;
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH)];
    self.iconView.backgroundColor = [UIColor whiteColor];
    [self.iconView setImage:[UIImage imageNamed:@""]];
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.height * 0.5;
    self.iconView.layer.masksToBounds = YES;
    [self.view addSubview:self.iconView];
    
    CGFloat nameLabelW = 202;
    CGFloat nameLabelH = (24/720.0) * self.view.bounds.size.height;
    CGFloat nameLabelX = (self.view.bounds.size.width - nameLabelW) * 0.5;
    CGFloat nameLabelY = CGRectGetMaxY(self.iconView.frame) + (24/667.0) * self.view.bounds.size.height;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
    self.nameLabel.text = @"";
    self.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.nameLabel.font = [UIFont systemFontOfSize:nameLabelH];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.nameLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.textColor = [UIColor colorWithRed:216/255.0 green:42/255.0 blue:42/255.0 alpha:1.0];
    self.priceLabel.font = [UIFont systemFontOfSize:nameLabelH];
    CGFloat priceLabelW = [self.priceLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width * 0.5, 36) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.priceLabel.font} context:nil].size.width;
    CGFloat priceLabelH = nameLabelH;
    CGFloat priceUnitLabelW = 12;
    CGFloat priceLabelY = CGRectGetMaxY(self.nameLabel.frame) + (40/667.0) * self.view.bounds.size.height;
    CGFloat priceLabelX = (self.view.bounds.size.width - priceUnitLabelW - priceLabelW) * 0.5;
    self.priceLabel.frame = CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH);
    [self.view addSubview:self.priceLabel];
    
    CGFloat priceUnitLabelY = (kDevice_Is_iPhone4 || kDevice_Is_iPhone5) ? priceLabelY + (priceLabelH - priceUnitLabelW) * 0.95 : priceLabelY + (priceLabelH - priceUnitLabelW) * 0.75;
    self.priceUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.priceLabel.frame), priceUnitLabelY, priceUnitLabelW, priceUnitLabelW)];
    self.priceUnitLabel.text = @"元";
    self.priceUnitLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    self.priceUnitLabel.font = [UIFont systemFontOfSize:(12/667.0) * self.view.bounds.size.height];
    [self.view addSubview:self.priceUnitLabel];
    
    CGFloat deseyxLabelW = 55;
    CGFloat receiveSucessLabelW = 63;
    CGFloat receiveSucessLabelH = 12;
    CGFloat receiveSucessLabelX = (self.view.bounds.size.width - receiveSucessLabelW - deseyxLabelW) * 0.5;
    CGFloat receiveSucessLabelY = CGRectGetMaxY(self.priceLabel.frame) + (24/667.0) * self.view.bounds.size.height;
    self.receiveSucessLabel = [[UILabel alloc] initWithFrame:CGRectMake(receiveSucessLabelX, receiveSucessLabelY, receiveSucessLabelW, receiveSucessLabelH)];
    self.receiveSucessLabel.text = @"领取成功，";
    self.receiveSucessLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    self.receiveSucessLabel.font = [UIFont systemFontOfSize:12];
    self.receiveSucessLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.receiveSucessLabel];
    
    self.deseyxLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.receiveSucessLabel.frame), self.receiveSucessLabel.frame.origin.y, deseyxLabelW, self.receiveSucessLabel.bounds.size.height)];
    self.deseyxLabel.userInteractionEnabled = YES;
    self.deseyxLabel.text = @"得瑟一下";
    self.deseyxLabel.textColor = [UIColor colorWithRed:232/255.0 green:37/255.0 blue:31/255.0 alpha:1.0];
    self.deseyxLabel.font = [UIFont systemFontOfSize:12];
    self.deseyxLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.deseyxLabel];

    self.jiluView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + ((24/667.0) * self.view.bounds.size.height)*2 + 12 + 24 + (40/667.0) * self.view.bounds.size.height, self.view.bounds.size.width, 24)];
    self.jiluView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0];
    [self.view addSubview:self.jiluView];
    
    self.jiluZiLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 80, self.jiluView.bounds.size.height)];
    self.jiluZiLabel.text = @"红包纪录";
    self.jiluZiLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.jiluZiLabel.font = [UIFont systemFontOfSize:12];
    [self.jiluView addSubview:self.jiluZiLabel];
    
    CGFloat lookMyPacketBtnH = (60/720.0) * self.view.bounds.size.height;
    CGFloat lookMyPacketBtnY = self.view.bounds.size.height - lookMyPacketBtnH;
    self.lookMyPacketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, lookMyPacketBtnY, self.view.bounds.size.width, lookMyPacketBtnH)];
    [self.lookMyPacketBtn setTitle:@"查看我的红包" forState:UIControlStateNormal];
    [self.lookMyPacketBtn setTitleColor:[UIColor colorWithRed:83/255.0 green:115/255.0 blue:117/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.lookMyPacketBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.lookMyPacketBtn.alpha = 0.0;
    self.lookMyPacketBtn.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    [self.view addSubview:self.lookMyPacketBtn];
    
    UIView *lookMyPacketBtnLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1.0)];
    lookMyPacketBtnLineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self.lookMyPacketBtn addSubview:lookMyPacketBtnLineView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.jiluView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.jiluView.frame) - lookMyPacketBtnH)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    [self.view addSubview:self.tableView];
    
//    if (self.type != Double12AwardViewControllerNewRedPacket || self.type != Double12AwardViewControllerPacketOver) {
        [self setupTabelFooterView];
//    }
    
    // 可拆红包和被领完了的背景
    if (self.type == Double12AwardViewControllerNewRedPacket || self.type == Double12AwardViewControllerPacketOver) {
        self.priceLabel.text = @"";
        self.priceUnitLabel.text = @"";
        self.receiveSucessLabel.text = @"";
        self.deseyxLabel.text = @"";
        self.jiluZiLabel.text = @"";
        self.jiluView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.userInteractionEnabled = NO;
        self.tableView.tableFooterView = nil;
        
        self.bottomImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.bottomImageView.userInteractionEnabled = YES;
        self.bottomImageView.image = [UIImage imageNamed:@"double12_bg"];
        [self.view addSubview:self.bottomImageView];
        [self.view insertSubview:self.bottomImageView atIndex:0];
        self.nameLabel.textColor = [UIColor whiteColor];
        
        if (self.type == Double12AwardViewControllerNewRedPacket) {
            CGFloat chaihongbaoBtnW = 232;
            CGFloat chaihongbaoBtnH = 48;
            CGFloat chaihongbaoBtnX = (self.view.bounds.size.width - chaihongbaoBtnW) * 0.5;
            CGFloat chaihongbaoBtnY = self.view.bounds.size.height - (72/667.0) * self.view.bounds.size.height - chaihongbaoBtnH;
            UIButton *chaihongbaoBtn = [[UIButton alloc] initWithFrame:CGRectMake(chaihongbaoBtnX, chaihongbaoBtnY, chaihongbaoBtnW, chaihongbaoBtnH)];
            chaihongbaoBtn.backgroundColor = [UIColor colorWithRed:244/255.0 green:217/255.0 blue:78/255.0 alpha:1.0];
            [chaihongbaoBtn setTitle:@"拆红包" forState:UIControlStateNormal];
            [chaihongbaoBtn setTitleColor:[UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0] forState:UIControlStateNormal];
            chaihongbaoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            chaihongbaoBtn.layer.cornerRadius = 10;
            chaihongbaoBtn.layer.masksToBounds = YES;
            [self.bottomImageView addSubview:chaihongbaoBtn];
            self.chaihongbaoBtn = chaihongbaoBtn;
            [chaihongbaoBtn addTarget:self action:@selector(chaihongbaoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        } else if (self.type == Double12AwardViewControllerPacketOver) {
            [self setupQwLabel];
        }
    }
    
    if (self.type == Double12AwardViewControllerHasRecord) {
        [self setupNameText];
    }

    [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.lookMyPacketBtn addTarget:self action:@selector(lookMyPacketBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)coverViewDidClick:(UIGestureRecognizer *)grz
{
    [self dropOutCoverView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestInfo];
}

- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.xRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Double12AwardViewCell";
    Double12AwardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[Double12AwardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.row = self.xRecords[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)chaihongbaoBtnDidClick
{
    self.currentPage = 1;
    [self requestOpenRedPacketNet];
}

- (void)requestInfo
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/McenterIndexAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.info = [[responseObject objectForKey:@"data"] firstObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestOpenRedPacketNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/GrabRedPackageAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 2], @"word":self.password, @"begin": [NSString stringWithFormat:@"%d", self.currentPage], @"size": @"10"};
    
    [self.manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObjectresponseObject:%@", responseObject);
//      responseObject = @{
//            @"error" : @"201",
//            @"msg": @"成功",
//            @"data": @[
//                     @{
//                         @"taskId": @"2687",
//                         @"result": @"1"
//                     },
//                     @{
//                         @"taskId": @"2684",
//                         @"rows": @[
//                                  @{
//                                      @"get_money": @"2",
//                                      @"get_time": @"",
//                                      @"login_name": @"test123",
//                                      @"m": @"1"
//                                  },
//                                  @{
//                                      @"get_money": @"3",
//                                      @"get_time": @"",
//                                      @"login_name": @"",
//                                      @"m": @"0"
//                                  },
//                                  @{
//                                      @"get_money": @"1",
//                                      @"get_time": @"",
//                                      @"login_name": @"",
//                                      @"m": @"0"
//                                  },
//                                  @{
//                                      @"get_money": @"4",
//                                      @"get_time": @"",
//                                      @"login_name": @"",
//                                      @"m": @"0"
//                                  }
//                                  ]
//                     }
//                     ]
//            };
        if ([responseObject[@"error"] intValue] == 201) {
            if ([[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"result"] intValue] == 1) { // 已抢到红包
                
                NSDictionary *dict2688 = [NSDictionary dictionary];
                NSDictionary *dict2684 = [NSDictionary dictionary];
                for (NSDictionary *dict in [responseObject objectForKey:@"data"]) {
                    
                    if ([[dict objectForKey:@"taskId"] integerValue] == 2688) {
                        if ([[dict objectForKey:@"rows"] count]) {
                            dict2688 = [dict objectForKey:@"rows"];
                        }
                    }
                    if ([[dict objectForKey:@"taskId"] integerValue] == 2684) {
                        if ([[dict objectForKey:@"rows"] count]) {
                            dict2684 = dict;
                        }
                    }
                }
            
                NSArray *records = [dict2684 objectForKey:@"rows"];
                if (self.currentPage == 1) {
                    [self abortBottomImageView:records]; // 退出abortBottomImageView
                } else {
                    if (!records.count) {
                        self.tableFooterLabel.text = @"没有更多了";
                        self.tableFooterLabel.userInteractionEnabled = NO;
                    } else {
                        self.xRecords = [[self.xRecords arrayByAddingObjectsFromArray:records] mutableCopy];
                    }
                }
            } else {
                self.tableFooterLabel.text = @"没有更多了";
                self.tableFooterLabel.userInteractionEnabled = NO;
                [self setupQwLabel];
            }
        } else {
            self.tableFooterLabel.text = @"没有更多了";
            self.tableFooterLabel.userInteractionEnabled = NO;
        }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestShare
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ShareActiveServlet.do"];
    NSDictionary *parameters = @{@"share_id": Double12HomeViewControllerShareId};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.shareDict = [[responseObject objectForKey:@"data"] firstObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}


- (void)abortBottomImageView:(NSArray *)records
{
    CGRect rect = self.bottomImageView.frame;
    rect.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomImageView.frame = rect;
    } completion:^(BOOL finished) {
        self.xRecords = [NSMutableArray arrayWithArray:records];
        self.jiluZiLabel.text = @"";
        self.jiluView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
        self.tableView.userInteractionEnabled = YES;
        self.jiluZiLabel.text = @"红包纪录";
        self.lookMyPacketBtn.alpha = 1.0;
        [self setupShareBtn];
        [self setupNameText];
        [self setupTabelFooterView];
        [self.tableView reloadData];
    }];
}

- (void)setupShareBtn
{
    [self.shareBtn removeFromSuperview];
    self.shareBtn = nil;
    self.shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 45, 20, 45, 44)];
    [self.shareBtn setImage:[UIImage imageNamed:@"double12_send"] forState:UIControlStateNormal];
    self.shareBtn.imageEdgeInsets = UIEdgeInsetsMake(13.665, 12.835, 13.665, 12.835);
    [self.view addSubview:self.shareBtn];
    [self.shareBtn addTarget:self action:@selector(shareBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupNameText
{
    self.iconView.layer.borderWidth = 1;
    self.iconView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
    NSDictionary *meDict = [NSDictionary dictionary];
    for (NSDictionary *record in self.xRecords) {
        if ([[record objectForKey:@"m"] intValue] == 1) {
            meDict = record;
        }
    }
    self.nameLabel.text = [meDict objectForKey:@"login_name"];
    self.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [[meDict objectForKey:@"get_money"] doubleValue]/100.0];
    self.priceLabel.textColor = [UIColor colorWithRed:216/255.0 green:42/255.0 blue:42/255.0 alpha:1.0];
    self.priceUnitLabel.text = @"元";
    self.receiveSucessLabel.text = @"领取成功，";
    self.deseyxLabel.text = @"得瑟一下";
    self.lookMyPacketBtn.alpha = 1.0;
    CGRect priceRect = self.priceLabel.frame;
    priceRect.size.width = [self.priceLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width * 0.5, 36) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.priceLabel.font} context:nil].size.width;
    priceRect.origin.x = (self.view.bounds.size.width - 12 - priceRect.size.width) * 0.5;
    self.priceLabel.frame = priceRect;
    CGRect priceUnitRect = self.priceUnitLabel.frame;
    priceUnitRect.origin.x = CGRectGetMaxX(self.priceLabel.frame);
    self.priceUnitLabel.frame = priceUnitRect;
    
    [self.deseyxLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deseyxLabelDidClick)]];
}

- (void)setupQwLabel
{
    UILabel *qwLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + (95/667.0) * self.view.bounds.size.height, self.view.bounds.size.width, 24)];
    qwLabel.text = @"来晚一步, 红包被领完了!";
    qwLabel.textColor = [UIColor colorWithRed:254/255.0 green:209/255.0 blue:44/255.0 alpha:1.0];
    qwLabel.textAlignment = NSTextAlignmentCenter;
    qwLabel.font = [UIFont systemFontOfSize:24];
    [self.bottomImageView addSubview:qwLabel];
    [self.chaihongbaoBtn removeFromSuperview];
}

- (void)setupTabelFooterView
{
    [self.tableFooterLabel removeFromSuperview];
    self.tableFooterLabel = nil;
    self.tableView.tableFooterView = nil;
    self.tableFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 24)];
    self.tableFooterLabel.userInteractionEnabled = YES;
    self.tableFooterLabel.backgroundColor = [UIColor whiteColor];
    self.tableFooterLabel.text = @"加载更多";
    self.tableFooterLabel.textColor = [UIColor colorWithRed:83/255.0 green:115/255.0 blue:177/255.0 alpha:1.0];
    self.tableFooterLabel.textAlignment = NSTextAlignmentCenter;
    self.tableFooterLabel.font = [UIFont systemFontOfSize:12];
    self.tableView.tableFooterView = self.tableFooterLabel;
    [self.tableFooterLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableFooterLabelDidClick)]];
}

- (void)tableFooterLabelDidClick
{
    if (self.currentPage == 1) {
        self.currentPage ++;
    }
    [self requestOpenRedPacketNet];
//    NSMutableArray *xRecords = [NSMutableArray array];
//    [xRecords addObjectsFromArray:self.records];
//    self.xRecords = xRecords;
//    [self.tableView reloadData];

}

- (void)lookMyPacketBtnDidClick
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/m-center/hongbao/index.html"];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchOuterWebViewWithURLString:overUrlStr];
}

- (void)launchOuterWebViewWithURLString:(NSString *)urlString {
    XCZDouble12WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZDouble12WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)shareBtnDidClick
{
    [self.view endEditing:YES];
    [self requestShare];
}

- (void)deseyxLabelDidClick
{
    [self.view endEditing:YES];
    [self requestShare];
}

/**
 *  退出分享View
 */
- (void)dropOutCoverView
{
    [self.coverView removeFromSuperview];
    self.coverView = nil;
    CGRect shareChannelPickerViewRect = self.shareChannelPickerView.frame;
    shareChannelPickerViewRect.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.shareChannelPickerView.frame = shareChannelPickerViewRect;
    }];
}

#pragma mark - XCZShareChannelPickerViewDelegate
/**
 *  取消按钮被点击
 */
- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView cancelBtnDidClick:(UIButton *)cancelBtn
{
    [self dropOutCoverView];
}

- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView iconViewDidClick:(XCZShareChannelIconView *)iconView
{
    NSString *title = [self.shareDict objectForKey:@"share_title"];
    NSString *description = [self.shareDict objectForKey:@"share_content"];
    NSString *share_url = [self.shareDict objectForKey:@"share_url"];
    //    title = @"###阿克苏的贺卡收到###";
    //    description = @"###dfggfds收到反馈和挥洒分开后撒伕欢快的洒分开还是大哥好看的方式###";
    NSString *priceLabelStr = [NSString stringWithFormat:@"%@", self.priceLabel.text];
    title = [title stringByReplacingOccurrencesOfString:@"###get_money###" withString:priceLabelStr];
    description = [description stringByReplacingOccurrencesOfString:@"###get_money###" withString:priceLabelStr];
    share_url = [description stringByReplacingOccurrencesOfString:@"####get_money####" withString:priceLabelStr];
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = title;
    mediaMessage.description = description;
    [mediaMessage setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.shareDict objectForKey:@"share_img"]]]]];
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = share_url;
    mediaMessage.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = mediaMessage;
    if ([iconView.shareRow[@"ShareMessageChannel"] isEqualToString:@"ShareMessageChannelWeixinSession"]) { // 分享到微信聊天界面
        if ([WXApi isWXAppInstalled]) {
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        } else {
            [MBProgressHUD ZHMShowError:@"没有安装微信"];
        }
    } else if ([iconView.shareRow[@"ShareMessageChannel"] isEqualToString:@"ShareMessageChannelWeixinTimeline"]) { // 分享到微信朋友圈
        if ([WXApi isWXAppInstalled]) {
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
        } else {
            [MBProgressHUD ZHMShowError:@"没有安装微信"];
        }
    }
}



@end
