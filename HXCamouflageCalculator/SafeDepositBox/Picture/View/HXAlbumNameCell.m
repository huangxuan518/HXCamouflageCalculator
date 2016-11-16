//
//  HXAlbumNameCell.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXAlbumNameCell.h"

@interface HXAlbumNameCell ()

@end

@implementation HXAlbumNameCell {
    UIImage *image;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {
    _delegate  = delegate;
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = data;
        NSString *title = dic[@"albumName"];
        _textField.text = title;
    }
}

- (IBAction)textFieldChange:(UITextField *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(currencyFirstCell:textField:)]) {
        [_delegate currencyFirstCell:self textField:_textField];
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
    return 44;
}

@end
