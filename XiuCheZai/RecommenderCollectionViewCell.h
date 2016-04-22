//
//  RecommenderCollectionViewCell.h
//  XiuCheZai
//
//  Created by QSH on 16/4/21.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommenderCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceStrikethroughLabel;

@end
