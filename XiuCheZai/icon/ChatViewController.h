//
//  ViewController.h
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *senderAvatar;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;
@property (strong, nonatomic) NSString *receiverAvatar;

@end
