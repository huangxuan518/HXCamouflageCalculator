//
//  HXCalculatorViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXCalculatorViewController.h"
#import "HXCalculatorKeyboardView.h"

#import "AppDelegate.h"

@interface HXCalculatorViewController () <HXCalculatorKeyboardViewDelegate>

@property (nonatomic,strong) UILabel *displayLabel;//显示屏Label
@property (nonatomic,strong) HXCalculatorKeyboardView *keyboardView; //计算器键盘

@end

@implementation HXCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:32/255.0 green:32/255.0 blue:32/255.0 alpha:1.0];
    
    //屏幕宽度
    float mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
    //屏幕高度
    float mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //将屏幕宽度分成4份，每份正方形块的长宽为
    float singleBlockHeight = mainScreenWidth/4;
    
    float orginY = mainScreenHeight - 5*singleBlockHeight;
    
    //显示屏
    _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, orginY - 15 - 80, mainScreenWidth - 50, 80)];
    _displayLabel.textAlignment = NSTextAlignmentRight;
    _displayLabel.font = [UIFont fontWithName:@"Avenir-Light" size:80];
    _displayLabel.backgroundColor = [UIColor clearColor];
    _displayLabel.text = @"0";
    _displayLabel.adjustsFontSizeToFitWidth = YES;
    _displayLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_displayLabel];
    
    _keyboardView = [[HXCalculatorKeyboardView alloc] initWithFrame:CGRectMake(0, orginY, mainScreenWidth, mainScreenHeight - orginY)];
    _keyboardView.delegate = self;
    [self.view addSubview:_keyboardView];
}

- (void)calculatorKeyboardView:(HXCalculatorKeyboardView *)keyboardView showCalculationResult:(NSString *)result {
    
    //去掉科学计数法中间的+号
    NSString *resultStr = [NSString ittemThousandPointsFromNumString:result];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"e+0" withString:@"e"];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"e+" withString:@"e"];
    _displayLabel.text = resultStr;
}

//进入隐藏界面
- (void)enterTheHiddenInterface {
    [self gotovc];
}

- (void)gotovc {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app cutViewController:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
