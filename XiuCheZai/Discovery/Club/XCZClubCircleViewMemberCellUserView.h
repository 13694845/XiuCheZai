//
//  XCZClubCircleViewMemberCellUserView.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCZClubCircleViewMemberCellUserView : UIView

/** 0代表会长部分， 1代表全体会员部分 */
@property (nonatomic, assign) int type;
@property (nonatomic, assign) CGFloat cellW;
@property (strong, nonatomic) NSDictionary *row;

@end
