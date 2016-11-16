//
//  HXAlbumCoverImageCell.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXAlbumCoverImageCell.h"

@implementation HXAlbumCoverImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(id)data delegate:(id)delegate {    
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = data;
        NSData *data = dic[@"coverImageData"];
        _coverImageView.image = [UIImage imageWithData:data];
    }
}

@end
