//
//  HXNoAlbumsPointsView.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXNoAlbumsPointsView.h"

@implementation HXNoAlbumsPointsView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
        _pointsLabel.font = [UIFont systemFontOfSize:14];
        _pointsLabel.textColor = [UIColor whiteColor];
        _pointsLabel.textAlignment = NSTextAlignmentCenter;
        _pointsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_pointsLabel];
    }
    
    return self;
}

@end
