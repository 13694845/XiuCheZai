//
//  TestChatViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "TestChatViewController.h"

@interface TestChatViewController ()


@property (weak, nonatomic) IBOutlet UITextField *senderId;
@property (weak, nonatomic) IBOutlet UITextField *senderName;
@property (weak, nonatomic) IBOutlet UITextField *senderAvatar;

@property (weak, nonatomic) IBOutlet UITextField *receiverId;
@property (weak, nonatomic) IBOutlet UITextField *receiverName;
@property (weak, nonatomic) IBOutlet UITextField *receiverAvatar;

@end

@implementation TestChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testChat:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
