//
//  TestChatViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "TestChatViewController.h"
#import "ChatViewController.h"

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (IBAction)testChat:(id)sender {
    ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatViewController.senderId = self.senderId.text;
    chatViewController.senderName = self.senderName.text;
    chatViewController.senderAvatar = self.senderAvatar.text;

    chatViewController.receiverId = self.receiverId.text;
    chatViewController.receiverName = self.receiverName.text;
    chatViewController.receiverAvatar = self.receiverAvatar.text;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
