//
//  ReminderView.h
//  XiuCheZai
//
//  Created by QSH on 16/4/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReminderView;

@protocol ReminderViewDataSource <NSObject>

- (NSString *)textForReminderView:(ReminderView *)reminderView;

@end

@interface ReminderView : UIView

@property (weak, nonatomic) id <ReminderViewDataSource> dataSource;

- (void)reloadData;

@end
