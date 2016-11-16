//
//  HXPictureGroupCell.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPictureGroupCell.h"
#import "PictureGroupEntity.h"

@implementation HXPictureGroupCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {    
    if ([data[@"data"] isKindOfClass:[PictureGroupEntity class]]) {
        PictureGroupEntity *pictureGroupEntity = (PictureGroupEntity *)data[@"data"];
        NSString *groupName = pictureGroupEntity.name;
        NSInteger groupPhotoCount = pictureGroupEntity.count;
        NSData *logoData = pictureGroupEntity.logoData;
        
        _icoImageView.image = [UIImage imageWithData:logoData];
        _titleLabel.text = groupName;
        _countLabel.text = [NSString stringWithFormat:@"%ld photos",(long)groupPhotoCount];
    }
}

+ (float)getCellFrame:(id)msg {
    if ([msg isKindOfClass:[NSNumber class]]) {
        NSNumber *number = msg;
        float height = number.floatValue;
        if (height > 0) {
            return height;
        }
    }
    return 90;
}

@end
