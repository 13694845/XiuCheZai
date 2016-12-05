//
//  Double12AwardViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/11/24.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, Double12AwardViewControllerType) {
    /** 已经领取过该红包  */
    Double12AwardViewControllerHasRecord,
    /** 有新红包  */
    Double12AwardViewControllerNewRedPacket,
    /** 新红包被拆成功后  */
    Double12AwardViewControllerNewRedPacketOver,
    /** 红包被别人领完了  */
    Double12AwardViewControllerPacketOver
};

@interface Double12AwardViewController : UIViewController

@property (strong, nonatomic) NSDictionary *infoDict;
@property (nonatomic, copy)NSArray *records;
@property (assign, nonatomic) Double12AwardViewControllerType type;
@property (copy, nonatomic) NSString *password;

@end
