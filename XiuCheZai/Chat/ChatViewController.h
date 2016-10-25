//
//  ChatViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (copy, nonatomic) NSString *senderId;
@property (copy, nonatomic) NSString *senderName;
@property (copy, nonatomic) NSString *senderAvatar;

@property (copy, nonatomic) NSString *receiverId;
@property (copy, nonatomic) NSString *receiverName;
@property (copy, nonatomic) NSString *receiverAvatar;

@end
