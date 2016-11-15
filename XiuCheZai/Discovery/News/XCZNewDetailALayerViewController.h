//
//  XCZNewDetailALayerViewController.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//
//  资讯回复楼层 某一层详细
//

#import "XCZDiscoveryPageViewController.h"

@protocol XCZNewDetailALayerViewControllerDelegate <NSObject>

@optional
- (void)detailViewController:(UIViewController *)viewController bottomTextField:(UITextField *)bottomTextField;

@end

@interface XCZNewDetailALayerViewController : XCZDiscoveryPageViewController

@property (nonatomic, copy) NSString *artid;
@property (nonatomic, copy) NSString *art_cateid;
@property (nonatomic, copy) NSString *floor;
@property (nonatomic, copy) NSString *reply_id;

@property (nonatomic, weak) id<XCZNewDetailALayerViewControllerDelegate> delegate;

@end
