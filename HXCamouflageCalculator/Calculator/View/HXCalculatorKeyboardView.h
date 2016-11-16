//
//  HXCalculatorKeyboardView.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/10.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXCalculatorKeyboardView;

@protocol HXCalculatorKeyboardViewDelegate <NSObject>

- (void)calculatorKeyboardView:(HXCalculatorKeyboardView *)keyboardView showCalculationResult:(NSString *)result;
//进入隐藏界面
- (void)enterTheHiddenInterface;

@end

@interface HXCalculatorKeyboardView : UIView

@property (nonatomic,weak) id<HXCalculatorKeyboardViewDelegate> delegate;

@end
