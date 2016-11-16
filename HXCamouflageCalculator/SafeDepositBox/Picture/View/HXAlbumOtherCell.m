//
//  HXAlbumOtherCell.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXAlbumOtherCell.h"

@implementation HXAlbumOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(id)data delegate:(id)delegate {    
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = data;
        NSString *title = dic[@"title"];
        _titleLabel.text = title;
    }
}

@end
