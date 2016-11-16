//
//  HXNoAlbumsPointsCell.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXNoAlbumsPointsCell.h"

@implementation HXNoAlbumsPointsCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {    

}

+ (float)getCellFrame:(id)msg {
    if ([msg isKindOfClass:[NSNumber class]]) {
        NSNumber *number = msg;
        float height = number.floatValue;
        if (height > 0) {
            return height;
        }
    }
    return 44;
}

@end
