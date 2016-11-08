//
//  XCZCircleDetailALayerViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleDetailALayerViewController.h"
#import "XCZConfig.h"
#import "XCZCircleDetailALayerRow.h"
#import "XCZCircleDetailALayerRowReplyView.h"
#import "DiscoveryConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZPersonInfoViewController.h"
#import "XCZPersonWebViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZKeyboardExpressionView.h"
#import "SMPageControl.h"
#import "XCZEmotionTextView.h"

@interface XCZCircleDetailALayerViewController ()<XCZCircleDetailALayerRowDelegate, UITextViewDelegate, XCZKeyboardExpressionViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, strong) NSDictionary *artDict; // 主界面主数据
@property (assign, nonatomic) int currentPage;

@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) int goType; // 0:为主帖去点赞，1为主帖评论, 2为下拉加载更多, 3为回复评论, 4为根贴点赞, 5为上拉刷新 6发送 7底部点赞 8.bottomView上遮盖被点击
@property (nonatomic, copy) NSString *publisher_id;
@property (nonatomic, copy) NSString *postContentText; // 发出的内容
@property (assign, nonatomic) CGPoint contentOffsetrequestQ; // 请求数据前contentOffset
@property (nonatomic, strong) NSDictionary *likeViewSubViews;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet XCZEmotionTextView *bottomTextView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTextViewPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *expressionBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) UIView *textFieldZheGaiView;
@property (weak, nonatomic) UIView *zeGaiView;
@property (assign, nonatomic) int praiseType; // 回帖点赞类型:0:去点赞, 1:取消点赞
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (assign, nonatomic) int gongJinru;
@property (assign, nonatomic) BOOL isExpressionViewShow;
@property (nonatomic, weak) XCZKeyboardExpressionView *expressionView;

@property (assign, nonatomic) int selectedBottomBtn;  // 1为表情 2为输入框



@end

@implementation XCZCircleDetailALayerViewController

@synthesize artDict = _artDict;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    if (self.goType == 3) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"post_id" : self.post_id,
                               @"forum_id" : self.artDict[@"forum_id"],
                               @"reply_content" : self.postContentText,
                               @"reply_id" : self.reply_id,
                               @"is_anony" : @"0",
                               };
        [self requestReplyPost:dict];
    } else if (self.goType == 4) {
        NSDictionary *dict = @{
                               @"type" : @"0",
                               @"posts_clazz" : @"2",
                               @"post_id" : self.publisher_id,
                               @"host" : self.post_id
                               };
        [self requestPraise:dict];
    } else if (self.goType == 6) {
    } else if (self.goType == 7) {
    } else if (self.goType == 8) { // bottomView上遮盖被点击
        if (loginStatu) {
            [self goLogining];
        } else {
            [self.textFieldZheGaiView removeFromSuperview];
            self.textFieldZheGaiView = nil;
            [self.bottomView becomeFirstResponder];
        }
    }
}

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    
    self.bottomTextView.text = nil;
    self.publisher_id = artDict[@"user_id"];
    if (!self.gongJinru) {
        self.gongJinru++;
    }
    [self creatSubview];
}

- (NSDictionary *)artDict
{
    if (!_artDict) {
        _artDict = [NSDictionary dictionary];
    }
    return _artDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self assistedSetup]; // 辅助设置
    [self loadData];
    [self changeNot]; // 通知处理
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assistedSetup
{
    self.title = @"评论详情";
    self.scrollView.alwaysBounceVertical = YES;

    self.gongJinru = 0;
    self.isExpressionViewShow = NO;
    self.bottomTextView.layer.cornerRadius = 5.0;
    self.bottomTextView.layer.masksToBounds = YES;
    self.bottomTextView.layer.borderWidth = 1.0;
    self.bottomTextView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0  blue:221/255.0  alpha:1.0].CGColor;
    self.bottomTextView.delegate = self;
    [self createTextFieldZheGaiView];
    
    self.bottomTextViewPlaceholderLabel.userInteractionEnabled = YES;
    [self.bottomTextViewPlaceholderLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomTextViewPlaceholderLabelDidClick)]];
    
    [self.expressionBtn addTarget:self action:@selector(expressionBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBtn addTarget:self action:@selector(sendBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createTextFieldZheGaiView
{
    UIView *textFieldZheGaiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.bounds.size.width, self.bottomView.bounds.size.height)];
    [self.bottomView addSubview:textFieldZheGaiView];
    self.textFieldZheGaiView = textFieldZheGaiView;
    [self.textFieldZheGaiView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldZheGaiViewDidClick:)]];
}

- (void)createZeGaiView
{
    UIView *zeGaiView = [[UIView alloc] init];
    zeGaiView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
     [self.view addSubview:zeGaiView];
    self.zeGaiView = zeGaiView;
    [self.zeGaiView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zeGaiViewDidClick:)]];
    [self.view insertSubview:self.bottomView aboveSubview:self.zeGaiView];
}

- (void)changeNot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)loadData {
    [self refreshData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)loadDataNeedsRefresh {
    self.currentPage = 1;
    [self requestNet];
}

- (void)clearDataNeedsRefresh {
    self.contentOffsetrequestQ = self.scrollView.contentOffset;
    [self.contentView removeFromSuperview];
    self.contentView = nil;
}

- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1], @"post_id":self.post_id, @"reply_id": self.reply_id, @"pagesize":[NSString stringWithFormat:@"%d", 10], @"page": [NSString stringWithFormat:@"%d", self.currentPage]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.artDict = [[responseObject objectForKey:@"data"] firstObject];
        [self endHeaderRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
    }];
}

- (void)requestReplyPost:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ReplyPostAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"error"] intValue] == 201) {
            [MBProgressHUD ZHMShowSuccess:@"评论成功"];
            [self loadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/DianZanAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"error"] containsString:@"未登录"]) {
            self.goType = 4;
            [self goLogining];
        } else if ([responseObject[@"error"] intValue] == 201) {
            UILabel *likeLabel = [self.likeViewSubViews objectForKey:@"likeLabel"];
            likeLabel.text = nil;
            likeLabel.text = [NSString stringWithFormat:@"%d", [likeLabel.text intValue] + 1];
        } else if ([responseObject[@"error"] intValue] == 333) {
            [MBProgressHUD ZHMShowError:@"您已经点过赞了"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"errorssss:%@", error);
        //        [self endHeaderRefresh];
    }];
}

/**
 *  监测登录
 */
- (void)requestLoginDetection
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.loginStatu = [responseObject[@"statu"] intValue];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)creatSubview
{
    self.height = 0.0;
    self.remarkHeight = 0.0;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 700)];
    [self.scrollView addSubview:self.contentView];
    
    UIView *remarkView = [[UIView alloc] init];
    remarkView.userInteractionEnabled = YES;
    remarkView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, 500);
    [self.contentView addSubview:remarkView];
    self.remarkView = remarkView;
    
    XCZCircleDetailALayerRow *remarkRow = [[XCZCircleDetailALayerRow alloc] init];
    remarkRow.delegate = self;
    remarkRow.type = 1; // 1代表资讯回复楼层 某一层详细传入
    remarkRow.fatherWidth = remarkView.bounds.size.width;
    remarkRow.floor = self.floor;
    if (self.louzhuId) {
        remarkRow.louzhuId = self.louzhuId;
    } else {
        remarkRow.louzhuId = @"";
    }
    
    remarkRow.remark = self.artDict;
    CGFloat remarkRowY = self.remarkHeight;
    remarkRow.frame = CGRectMake(0, remarkRowY, remarkView.bounds.size.width, remarkRow.height);
    self.remarkHeight += remarkRow.height;
    [remarkView addSubview:remarkRow];
    
    CGRect remarkViewRect = self.remarkView.frame;
    remarkViewRect.size.height = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    self.remarkView.frame = remarkViewRect;
    self.height += self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    [self setupOutFrame];
}

- (void)setupOutFrame
{
    CGRect contentViewRect = self.contentView.frame;
    contentViewRect.size.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.contentView.frame = contentViewRect;
    
    CGSize contentViewSize = self.scrollView.contentSize;
    contentViewSize.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.scrollView.contentSize = contentViewSize;
}

#pragma mark - 通知方法
- (void)keyboardWillShow:(NSNotification *)notification
{
//    NSLog(@"bottomTextViewInputView:%@", [self.bottomTextView.inputView class]);
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        CGRect keyboardFrame = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
        CGRect viewRect = self.view.frame;
        viewRect.origin.y = -keyboardFrame.size.height + 64;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = viewRect;
        } completion:^(BOOL finished) {
            self.isExpressionViewShow = YES;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect viewRect = self.view.frame;
    viewRect.origin.y = 64;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewRect;
    } completion:^(BOOL finished) {
       self.isExpressionViewShow = NO;
        self.bottomTextView.inputView = nil;
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self createZeGaiView];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self.zeGaiView removeFromSuperview];
    self.zeGaiView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 代理方法
- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailALayerRowReplyView:(XCZCircleDetailALayerRowReplyView *)detailALayerRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews
{
    self.reply_id = detailALayerRow.remark[@"reply_id"];
    self.publisher_id = detailALayerRow.remark[@"user_id"];
    self.likeViewSubViews = likeViewSubViews;
    self.goType = 4;
    [self requestLoginDetection];
}

- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow replyViewDidClick:(UIView *)replyView
{
    self.reply_id = detailALayerRow.remark[@"reply_id"];
    [self.bottomView becomeFirstResponder];
    
}

- (void)bottomTextViewPlaceholderLabelDidClick
{
    if (self.selectedBottomBtn == 1) {
        if (self.isExpressionViewShow) {
            [self.bottomTextView resignFirstResponder];
        }
        self.selectedBottomBtn = 2;
    } else {
        self.bottomTextView.inputView = nil;
        [self.bottomTextView becomeFirstResponder];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.bottomTextViewPlaceholderLabel.text = @"";
    } else {
        self.bottomTextViewPlaceholderLabel.text = @"回复 用户名:";
    }
    
    // 处理textView及inputView跟随文本高度变化而变化
//    NSLog(@"bottomViewHeight:%@", self.bottomViewHeight);
    CGSize contentSize = textView.contentSize;
    CGFloat contentH = contentSize.height; // 获取contentSize
    if (contentH <= 138) { // 大于33，超过一行的高度/ 小于68 高度是在三行内
        self.bottomViewHeight.constant = contentH + 15;
    }
    
//    // 处理存表情时光标不能显示的问题
//    if (self.keyboardType == 2) {
//        CGRect line = [textView caretRectForPosition:
//                       textView.selectedTextRange.start];
//        CGFloat overflow = line.origin.y + line.size.height
//        - ( textView.contentOffset.y + textView.bounds.size.height
//           - textView.contentInset.bottom - textView.contentInset.top);
//        
//        if ( overflow > 0 ) {
//            CGPoint offset = textView.contentOffset;
//            offset.y += overflow + 7;
//            [UIView animateWithDuration:.2 animations:^{
//                [textView setContentOffset:offset];
//            }];
//        }
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (void)expressionView:(XCZKeyboardExpressionView *)expressionView exBtnDidClick:(XCZExBtn *)exBtn
{
    if (![exBtn.expression[@"name"] isEqualToString:@"compose_emotion_delete"]) { // 点击的非叉叉
       [self.bottomTextView appendEmotion:exBtn.expression];
       self.postContentText = [self.bottomTextView fullTextWithExpression];
    } else { // 点击的是x
        NSMutableAttributedString *attributedText = [self.bottomTextView.attributedText mutableCopy];
        [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            
            XCZTextAttachment *attach = attrs[@"NSAttachment"];
            NSRange wrang = range;
            if (attach) {
                NSAttributedString *lastAttrs = [attributedText attributedSubstringFromRange:NSMakeRange(attributedText.length - 1, 1)];
                
                [lastAttrs enumerateAttributesInRange:NSMakeRange(0, lastAttrs.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                    
                    XCZTextAttachment *lastAttach = attrs[@"NSAttachment"];
                    if (lastAttach) { // 最后一个是表情
                        if (wrang.location == attributedText.length - 1) {
                            [attributedText deleteCharactersInRange:NSMakeRange(wrang.location, wrang.length)];
                            self.bottomTextView.attributedText = attributedText;
                        }
                    } else {
                        [attributedText deleteCharactersInRange:NSMakeRange(attributedText.length - 1, 1)];
                        self.bottomTextView.attributedText = attributedText;
                    }
                }];
            }
        }];
        self.postContentText = [self.bottomTextView fullTextWithExpression];
    }
    
//    NSLog(@"expression:%@", exBtn.expression);
   
//     NSMutableString *string = [NSMutableString string];
//    [self.bottomTextView.attributedText enumerateAttributesInRange:NSMakeRange(0, self.bottomTextView.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//        
//        [string appendString:[NSString stringWithFormat:@"[%@]", [UIImage imageNamed:exBtn.expression[@"name"]]]];
////        NSLog(@"string:%@", string);
//        self.bottomTextView = string;
//    }];
    
}

- (void)expressionBtnDidClick
{
    self.selectedBottomBtn = 1;
    XCZKeyboardExpressionView *expressionView = [[XCZKeyboardExpressionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 180)];
    expressionView.delegate = self;
    NSArray *emotes = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emotes.plist" ofType:nil]]; // 取出表情包
    expressionView.expressions = [emotes firstObject][@"expressions"];
    
    if (!self.isExpressionViewShow) {
        self.bottomTextView.inputView = expressionView;
        self.expressionView = expressionView;
        [self.bottomTextView becomeFirstResponder];
    } else {
        [self.bottomTextView resignFirstResponder];
    }
}

#pragma mark - 去登录等方法
- (void)goLogining
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/bbs/car-club/index.html"];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [XCZConfig baseURL], @"/Login/login/login.html?url=", overUrlStr]];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    XCZPersonWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonWebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 监听事件
/**
 *  收藏按钮被点击
 */
- (void)collectionBtnDidClick:(UIButton *)collectionBtn
{
    self.goType = 6;
    [self requestLoginDetection]; // 监测登录
}

- (void)praiseBtnDidClick:(UIButton *)praiseBtn
{
    self.goType = 7;
    [self requestLoginDetection]; // 监测登录
}

- (void)textFieldZheGaiViewDidClick:(UIGestureRecognizer *)grz
{
    self.goType = 8;
    
//    [self.zeGaiView removeFromSuperview];
//    self.zeGaiView = nil;
    [self requestLoginDetection]; // 监测登录
}

- (void)zeGaiViewDidClick:(UIGestureRecognizer *)grz
{
//    [self.zeGaiView removeFromSuperview];
//    self.zeGaiView = nil;
    [self.view endEditing:YES];
}

- (void)sendBtnDidClick
{
    CGRect viewRect = self.view.frame;
    viewRect.origin.y = 64;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewRect;
    } completion:^(BOOL finished) {
        self.isExpressionViewShow = NO;
    }];
    [self.view endEditing:YES];
    
    self.goType = 3;
    self.postContentText = [self.bottomTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.postContentText.length) {
        [MBProgressHUD ZHMShowError:@"说点再发送吧"];
        return;
    }
    [self requestLoginDetection];
    self.bottomTextView.text = @"";
    self.bottomViewHeight.constant = 48;
    
}

#pragma mark - 踢啊转控制器方法
/**
 *  跳转到XCZPersonInfoViewController
 */
- (void)jumpToPersonInfoVC:(NSString *)bbs_user_id
{
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
}

#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
    if (!self.indicatorHeaderView) {
        CGFloat indicatorHeaderViewW = 40;
        CGFloat indicatorHeaderViewH = indicatorHeaderViewW;
        CGFloat indicatorHeaderViewX = (scrollView.bounds.size.width - indicatorHeaderViewW) * 0.5;
        CGFloat indicatorHeaderViewY = - indicatorHeaderViewH;
        UIActivityIndicatorView *indicatorHeaderView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorHeaderViewX, indicatorHeaderViewY, indicatorHeaderViewW, indicatorHeaderViewH)];
        indicatorHeaderView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorHeaderView.hidden = NO;
        [scrollView addSubview:indicatorHeaderView];
        self.indicatorHeaderView = indicatorHeaderView;
    }
}

//- (void)morePullUpRefreshControl:(UIScrollView *)scrollView
//{
//    [self removeIndicatorHeaderView];
//    if (!self.indicatorFooterView) {
//        CGFloat indicatorFooterViewW = 40;
//        CGFloat indicatorFooterViewH = indicatorFooterViewW;
//        CGFloat indicatorFooterViewX = (scrollView.bounds.size.width - indicatorFooterViewW) * 0.5;
//        CGFloat indicatorFooterViewY = scrollView.contentSize.height;
//        UIActivityIndicatorView *indicatorFooterView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorFooterViewX, indicatorFooterViewY, indicatorFooterViewW, indicatorFooterViewH)];
//        indicatorFooterView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        indicatorFooterView.hidden = NO;
//        [scrollView addSubview:indicatorFooterView];
//        self.indicatorFooterView = indicatorFooterView;
//    }
//}

- (void)startHeaderRefresh:(UIScrollView *)scrollView
{
    [self.indicatorHeaderView startAnimating];
    [self refreshData];
}

//- (void)startFooterRefresh:(UIScrollView *)scrollView
//{
//    [self.indicatorFooterView startAnimating];
//    //    [self refreshData];
//}

- (void)endHeaderRefresh
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentOffset = offset;
        } completion:^(BOOL finished) {
            [self removeIndicatorHeaderView];
        }];
    });
}

//- (void)endFooterRefresh
//{
//    CGPoint offset = self.scrollView.contentOffset;
//    offset.y = 0;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.scrollView.contentOffset = offset;
//    } completion:^(BOOL finished) {
//        [self removeIndicatorFooterView];
//    }];
//}

- (void)stopHeaderScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    //    (scrollView.contentOffset.y < -75) ? offset.y = -75 : ((scrollView.contentOffset.y > 0) ? offset.y-- : offset.y++);
    ((scrollView.contentOffset.y < -75) ? (offset.y = -75) : (offset.y = 0));
    [scrollView setContentOffset:offset animated:YES];
}

//- (void)stopFooterScroll:(UIScrollView *)scrollView
//{
//    CGPoint offset = scrollView.contentOffset;
//    (scrollView.contentOffset.y < 75) ? (offset.y = 0) : (offset.y = 75);
//    scrollView.contentOffset = offset;
//    //    [scrollView setContentOffset:offset animated:];
//
//    [UIView animateWithDuration:1.0 animations:^{
//        if (offset.y >= 75) {
//            [self startFooterRefresh:scrollView];
//        } else {
//            [self removeIndicatorFooterView];
//        }
//    }];
//}

- (void)removeIndicatorHeaderView
{
    [self.indicatorHeaderView stopAnimating];
    [self.indicatorHeaderView removeFromSuperview];
    self.indicatorHeaderView = nil;
}

//- (void)removeIndicatorFooterView
//{
//    [self.indicatorFooterView stopAnimating];
//    [self.indicatorFooterView removeFromSuperview];
//    self.indicatorFooterView = nil;
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    //    if (scrollView.contentOffset.y > 75) { // 上拉加载更多
    //        [self morePullUpRefreshControl:scrollView];
    //        [self stopFooterScroll:scrollView];
    //    }
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
