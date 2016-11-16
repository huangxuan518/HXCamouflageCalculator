//
//  HXPictureGroupCell.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface HXPictureGroupCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
