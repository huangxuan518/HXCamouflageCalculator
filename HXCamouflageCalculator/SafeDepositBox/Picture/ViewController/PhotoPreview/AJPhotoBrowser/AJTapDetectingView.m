//
//  AJTapDetectingView.m
//  AJPhotoBrowser
//
//  Created by AlienJunX on 16/2/15.
//  Copyright (c) 2015 AlienJunX
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "AJTapDetectingView.h"

@implementation AJTapDetectingView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.exclusiveTouch = YES;
    }
    return self;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(viewSingleTapDetected:touch:)]) {
                [_delegate viewSingleTapDetected:self touch:touch];
            }
        }
            break;
            
        case 2:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(viewDoubleTapDetected:touch:)]) {
                [_delegate viewDoubleTapDetected:self touch:touch];
            }
        }
            break;
    }
}

- (void)dealloc {
    _delegate = nil;
}

@end
