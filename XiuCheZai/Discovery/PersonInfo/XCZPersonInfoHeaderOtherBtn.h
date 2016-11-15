//
//  XCZPersonInfoHeaderOtherBtn.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCZPersonInfoHeaderOtherBtn : UIButton

/** 1.ziLabel */
@property (nonatomic, weak) UILabel *ziLabel;
/** 2.valueLabel */
@property (nonatomic, weak) UILabel *valueLabel;
/** 3.竖线 */
@property (nonatomic, weak) UILabel *lineLabel;
@property (nonatomic, assign) CGFloat deatY;


///** 1.字 */
//@property(nonatomic, copy)NSString *textZi;
///** 2.值 */
//@property(nonatomic, copy)NSString *textValue;


@end
