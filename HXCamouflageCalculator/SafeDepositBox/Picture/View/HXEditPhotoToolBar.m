//
//  HXEditPhotoToolBar.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXEditPhotoToolBar.h"

@interface HXEditPhotoToolBar ()

@property (weak, nonatomic) IBOutlet UIButton *moveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation HXEditPhotoToolBar

+ (id)instanceView {
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

- (void)setSelectPictureCount:(NSInteger)selectPictureCount delegate:(id)delegate {
    _delegate  = delegate;
    if (selectPictureCount > 0) {
        _moveButton.enabled = YES;
        _deleteButton.enabled = YES;
    } else {
        _moveButton.enabled = NO;
        _deleteButton.enabled = NO;
    }
    
    _pointsLabel.text = [NSString stringWithFormat:@"%ld selected",(long)selectPictureCount];
    
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(editPhotoCountView:buttonAction:)]) {
        [_delegate editPhotoCountView:self buttonAction:sender];
    }
}

@end
