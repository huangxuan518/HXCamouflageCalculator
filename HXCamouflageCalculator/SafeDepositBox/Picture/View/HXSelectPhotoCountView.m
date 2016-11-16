//
//  HXSelectPhotoCountView.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXSelectPhotoCountView.h"

@implementation HXSelectPhotoCountView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        _pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
        _pointsLabel.font = [UIFont systemFontOfSize:14];
        _pointsLabel.textColor = [UIColor whiteColor];
        _pointsLabel.textAlignment = NSTextAlignmentCenter;
        _pointsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_pointsLabel];
    }
    
    return self;
}

- (void)buttonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectPhotoCountView:addButtonAction:)]) {
        [_delegate selectPhotoCountView:self addButtonAction:sender];
    }
}

@end
