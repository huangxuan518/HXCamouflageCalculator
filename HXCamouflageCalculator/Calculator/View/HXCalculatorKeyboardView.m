//
//  HXCalculatorKeyboardView.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/10.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXCalculatorKeyboardView.h"

typedef NS_ENUM(NSUInteger, KeyType) {
    KeyType_FunctionKeys = 1, //功能键 @"AC",@"+/-",@"%"
    KeyType_NumericKeys, //数字键 @"7",@"8",@"9",@"4",@"5",@"6",@"1",@"2",@"3",@"0",@"."
    KeyType_OperatorKeys, //运算符键 @"×",@"-",@"+",@"="
};

@interface HXCalculatorKeyboardView ()

@property (nonatomic,assign) NSInteger preOperatorButtonTag;//前一个运算符按键的tag
@property (nonatomic,copy) NSString *preDisplay;//前一次显示屏
@property (nonatomic,copy) NSString *currentDisplay;//当前显示屏
@property (nonatomic,copy) NSString *currentOperatorKey;//当前运算符
@property (nonatomic,assign) BOOL isClickOperatorKey;//是否点击运算符
@property (nonatomic,assign) BOOL isErro;//是否错误

@end

@implementation HXCalculatorKeyboardView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:32/255.0 green:32/255.0 blue:32/255.0 alpha:1.0];
        _preDisplay = @"";
        _currentDisplay = @"0";
        [self setup:frame];
    }
    
    return self;
}

- (NSArray *)keyboardDataAry {
    //键盘按键数据源控制 从上到下，0键占位2个，所以按0和空键响应事件都是0键
    NSArray *keyboardDataAry = @[
                                 @[
                                     @{@"keyName":@"AC",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_FunctionKeys]},
                                     
                                     @{@"keyName":@"+/-",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_FunctionKeys]},
                                     
                                     @{@"keyName":@"%",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_FunctionKeys]},
                                     
                                     @{@"keyName":@"÷",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_OperatorKeys]}
                                     ],
                                 
                                 @[
                                     @{@"keyName":@"7",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"8",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"9",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"×",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_OperatorKeys]}
                                     ],
                                 
                                 @[
                                     @{@"keyName":@"4",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"5",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"6",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"-",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_OperatorKeys]}
                                     ],
                                 
                                 @[
                                     @{@"keyName":@"1",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"2",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"3",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"+",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_OperatorKeys]}
                                     ],
                                 
                                 @[
                                     @{@"keyName":@"0",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@".",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_NumericKeys]},
                                     
                                     @{@"keyName":@"=",
                                       @"keyType":[NSNumber numberWithUnsignedInteger:KeyType_OperatorKeys]}
                                     ]
                                 ];
    return keyboardDataAry;
}


- (void)setup:(CGRect)frame {

    //将屏幕宽度分成4份，每份正方形块的长宽为 (先减去3条中线的宽度0.5*3) 最终结果取整数，这样是为了防止等分后结果为0.75这样的结果时，界面缝隙太大 如（375 - 1.5）/4
    int singleBlockWidth = (int)((frame.size.width - 1.5)/4);
    int singleBlockHeight = singleBlockWidth;
    
    NSArray *keyboardDataAry = self.keyboardDataAry;
    
    //是否0以后 0要占2格，之后的按键也要做特殊处理
    __block BOOL isZeroBehind = NO;
    
    [keyboardDataAry enumerateObjectsUsingBlock:^(NSArray *verticalArray, NSUInteger verticalIdx, BOOL * _Nonnull stop) {
        [verticalArray enumerateObjectsUsingBlock:^(NSDictionary *keyDic, NSUInteger horizontalIdx, BOOL * _Nonnull stop) {
            
            NSString *key = keyDic[@"keyName"];
            NSUInteger keyType = [keyDic[@"keyType"] integerValue];
            
            UIButton *keyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            keyButton.tag = verticalIdx*4+horizontalIdx + 1000;
            [keyButton setTitle:key forState:UIControlStateNormal];
            [keyButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            keyButton.backgroundColor = [UIColor clearColor];
            [keyButton addTarget:self action:@selector(keyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, keyButton.frame.size.width, keyButton.frame.size.height)];
            label.textColor = [UIColor blackColor];
            label.userInteractionEnabled = NO;
            label.text = key;
            label.tag = keyButton.tag*2;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Avenir-Light" size:25];
            
            //合并0键和空键为一个占2行的0键
            if ([key isEqualToString:@"0"]) {
                isZeroBehind = YES;
                keyButton.frame = CGRectMake(horizontalIdx*singleBlockWidth,verticalIdx*(singleBlockHeight+0.5), singleBlockWidth*2 + 0.5, singleBlockHeight);
                label.frame = CGRectMake(0, 0, keyButton.frame.size.width/2, keyButton.frame.size.height);
            } else {
                if (isZeroBehind) {
                    keyButton.frame = CGRectMake((horizontalIdx+1)*(singleBlockWidth + 0.5),verticalIdx*(singleBlockHeight+0.5), singleBlockWidth, singleBlockHeight);
                } else {
                    keyButton.frame = CGRectMake(horizontalIdx*(singleBlockWidth + 0.5),verticalIdx*(singleBlockHeight+0.5), singleBlockWidth, singleBlockHeight);
                }
                label.frame = CGRectMake(0, 0, keyButton.frame.size.width, keyButton.frame.size.height);
            }

            switch (keyType) {
                case KeyType_FunctionKeys:
                {
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:197/255.0 green:199/255.0 blue:201/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateNormal];
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:180/255.0 green:181/255.0 blue:182/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateHighlighted];
                }
                    break;
                    
                case KeyType_NumericKeys:
                {
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:212/255.0 green:213/255.0 blue:216/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateNormal];
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:190/255.0 green:191/255.0 blue:192/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateHighlighted];
                }
                    break;
                    
                case KeyType_OperatorKeys:
                {
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:249/255.0 green:143/255.0 blue:18/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateNormal];
                    [keyButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:224/255.0 green:122/255.0 blue:15/255.0 alpha:1.0] size:keyButton.frame.size] forState:UIControlStateHighlighted];
                    label.textColor = [UIColor whiteColor];
                }
                    break;
                    
                default:
                    break;
            }
            
            [keyButton addSubview:label];
            [self addSubview:keyButton];
        }];
    }];
}

- (void)keyButtonAction:(UIButton *)sender {
    
    if (_isErro) {
         [self keyAcChangeKeyC];
        
        _preDisplay = @"0";
        _currentOperatorKey = @"";
        _currentDisplay = @"0";
        _isClickOperatorKey = NO;
        _isErro = NO;
    }

    //点击其他符号需要将运算符的边框除去，点击+/-和%运算符的边框不做变化
    if (_preOperatorButtonTag > 0 && ![sender.titleLabel.text isEqualToString:@"+/-"] && ![sender.titleLabel.text isEqualToString:@"%"]) {
        UIButton *button = (UIButton *)[self viewWithTag:_preOperatorButtonTag];
        button.layer.borderColor = [UIColor clearColor].CGColor;
        button.layer.borderWidth = 0;
    }
    
    //点击运算符需要给运算符加上边框
    if ([sender.titleLabel.text isEqualToString:@"÷"] || [sender.titleLabel.text isEqualToString:@"×"] || [sender.titleLabel.text isEqualToString:@"-"] || [sender.titleLabel.text isEqualToString:@"+"]) {
        sender.layer.borderColor = [UIColor blackColor].CGColor;
        sender.layer.borderWidth = 1.0;
        
        _preOperatorButtonTag = sender.tag;
    }
    
    if ([_currentDisplay isEqualToString:@"0"] || [_currentDisplay isEqualToString:@"-0"]) {
        
        //当前显示屏显示0即为初始化
        if ([sender.titleLabel.text isEqualToString:@"0"] || [sender.titleLabel.text isEqualToString:@"1"] || [sender.titleLabel.text isEqualToString:@"2"] || [sender.titleLabel.text isEqualToString:@"3"] || [sender.titleLabel.text isEqualToString:@"4"] || [sender.titleLabel.text isEqualToString:@"5"] || [sender.titleLabel.text isEqualToString:@"6"] || [sender.titleLabel.text isEqualToString:@"7"] || [sender.titleLabel.text isEqualToString:@"8"] || [sender.titleLabel.text isEqualToString:@"9"] || [sender.titleLabel.text isEqualToString:@"."]) {
            [self keyAcChangeKeyC];
            
            if ([_currentOperatorKey isEqualToString:@"="]) {
                _currentDisplay = @"";
                _currentOperatorKey = @"";
            }

            //字符串查找
            if([_currentDisplay rangeOfString:@"."].location != NSNotFound && [sender.titleLabel.text isEqualToString:@"."]) {
                
            } else {
                if ([_currentDisplay isEqualToString:@"-0"]) {
                    if ([sender.titleLabel.text isEqualToString:@"."]) {
                        _currentDisplay = [@"-0" stringByAppendingString:sender.titleLabel.text];
                    } else {
                        _currentDisplay = [@"-" stringByAppendingString:sender.titleLabel.text];
                    }
                } else {
                    if ([sender.titleLabel.text isEqualToString:@"."]) {
                        _currentDisplay = [@"0" stringByAppendingString:sender.titleLabel.text];
                    } else {
                        _currentDisplay = [@"" stringByAppendingString:sender.titleLabel.text];
                    }
                }
            }
            
        } else if ([sender.titleLabel.text isEqualToString:@"+/-"]) {
            _currentDisplay = [NSString stringWithFormat:@"-%@",_currentDisplay];
            //字符串替换
            _currentDisplay = [_currentDisplay stringByReplacingOccurrencesOfString:@"--" withString:@""];
        } else if ([sender.titleLabel.text isEqualToString:@"%"] || [sender.titleLabel.text isEqualToString:@"AC"] || [sender.titleLabel.text isEqualToString:@"C"]) {
            _currentDisplay = @"0";
            _preDisplay = @"0";
            _currentOperatorKey = @"";
            
            //AC 点击后要变成 C，不停的切换
            if (sender.tag == 1000) {
                UILabel *label = (UILabel *)[self viewWithTag:sender.tag*2];
                if ([label.text isEqualToString:@"C"]) {
                    [sender setTitle:@"AC" forState:UIControlStateNormal];
                    label.text = @"AC";
                    _isClickOperatorKey = NO;
                }
            }
        } else {
            
            if ([_currentDisplay isEqualToString:@"错误"]) {
                
            } else {
            
                [self ittemsCalculationResult:_preDisplay currentOperatorKey:_currentOperatorKey currentDisplay:_currentDisplay];
                
                if ([sender.titleLabel.text isEqualToString:@"="]) {
                    _preDisplay = @"0";
                    _currentOperatorKey = @"";
                } else {
                    _currentOperatorKey = sender.titleLabel.text;
                }
            }
        }
    } else {
        
        if ([sender.titleLabel.text isEqualToString:@"0"] || [sender.titleLabel.text isEqualToString:@"1"] || [sender.titleLabel.text isEqualToString:@"2"] || [sender.titleLabel.text isEqualToString:@"3"] || [sender.titleLabel.text isEqualToString:@"4"] || [sender.titleLabel.text isEqualToString:@"5"] || [sender.titleLabel.text isEqualToString:@"6"] || [sender.titleLabel.text isEqualToString:@"7"] || [sender.titleLabel.text isEqualToString:@"8"] || [sender.titleLabel.text isEqualToString:@"9"] || [sender.titleLabel.text isEqualToString:@"."]) {
            
            if ([_currentOperatorKey isEqualToString:@"="]) {
                _currentDisplay = @"";
                _currentOperatorKey = @"";
            }
            
            if([_currentDisplay rangeOfString:@"."].location != NSNotFound && [sender.titleLabel.text isEqualToString:@"."]) {
                
            } else {
                if (_isClickOperatorKey) {
                    _currentDisplay = @"";
                    _isClickOperatorKey = NO;
                }
               _currentDisplay = [_currentDisplay stringByAppendingString:sender.titleLabel.text];
            }
        } else if ([sender.titleLabel.text isEqualToString:@"+/-"]) {
            _currentDisplay = [NSString stringWithFormat:@"-%@",_currentDisplay];
            //字符串替换
            _currentDisplay = [_currentDisplay stringByReplacingOccurrencesOfString:@"--" withString:@""];
        } else if ([sender.titleLabel.text isEqualToString:@"%"] || [sender.titleLabel.text isEqualToString:@"AC"]) {
            
            if ([sender.titleLabel.text isEqualToString:@"%"] && [_currentDisplay isEqualToString:@"8888"]) {
                //暗门
                if (_delegate && [_delegate respondsToSelector:@selector(enterTheHiddenInterface)]) {
                    [_delegate enterTheHiddenInterface];
                }
            }
            
            _currentDisplay = [NSString stringDisposeWithFloatStringValue:[NSString stringWithFormat:@"%f",_currentDisplay.floatValue/100]];
            
        } else {
            
            if ([_currentDisplay isEqualToString:@"错误"]) {
                
            } else {
                [self ittemsCalculationResult:_preDisplay currentOperatorKey:_currentOperatorKey currentDisplay:_currentDisplay];
                
                if ([sender.titleLabel.text isEqualToString:@"="]) {
                    _preDisplay = @"0";
                    _currentOperatorKey = @"=";
                } else {
                    _currentOperatorKey = sender.titleLabel.text;
                    _preDisplay = _currentDisplay;
                    _isClickOperatorKey = YES;
                }
            }
        }
        
        //AC 点击后要变成 C，不停的切换
        if (sender.tag == 1000) {
            UILabel *label = (UILabel *)[self viewWithTag:sender.tag*2];
            if ([label.text isEqualToString:@"AC"]) {
                [sender setTitle:@"C" forState:UIControlStateNormal];
                label.text = @"C";
                _preDisplay = @"0";
                _currentOperatorKey = @"";
                _currentDisplay = @"0";
            } else if ([label.text isEqualToString:@"C"]) {
                [sender setTitle:@"AC" forState:UIControlStateNormal];
                label.text = @"AC";
                _preDisplay = @"0";
                _currentOperatorKey = @"";
                _currentDisplay = @"0";
                _isClickOperatorKey = NO;
            }
        }
    }

    if (_delegate && [_delegate respondsToSelector:@selector(calculatorKeyboardView:showCalculationResult:)]) {
        [_delegate calculatorKeyboardView:self showCalculationResult:_currentDisplay];
    }
}

// AC变为C 只有当第一次输入数字时才会改变
- (void)keyAcChangeKeyC {
    UIButton *button = (UIButton *)[self viewWithTag:1000];
    UILabel *label = (UILabel *)[self viewWithTag:2000];
    if ([label.text isEqualToString:@"AC"]) {
        [button setTitle:@"C" forState:UIControlStateNormal];
        label.text = @"C";
    }
}

//计算结果
- (void)ittemsCalculationResult:(NSString *)preDisplay currentOperatorKey:(NSString *)currentOperatorKey currentDisplay:(NSString *)currentDisplay {
    
    if ([currentOperatorKey isEqualToString:@"+"]) {
        _currentDisplay = [NSString stringWithFormat:@"%f",preDisplay.floatValue + currentDisplay.floatValue];
    } else if ([currentOperatorKey isEqualToString:@"-"]) {
        _currentDisplay = [NSString stringWithFormat:@"%f",preDisplay.floatValue - currentDisplay.floatValue];
    } else if ([currentOperatorKey isEqualToString:@"×"]) {
        _currentDisplay = [NSString stringWithFormat:@"%f",preDisplay.floatValue * currentDisplay.floatValue];
    } else if ([currentOperatorKey isEqualToString:@"÷"]) {
        if (preDisplay.floatValue > 0 && ([currentDisplay isEqualToString:@"0"] || [currentDisplay isEqualToString:@"-0"])) {
            _isErro = YES;
        } else {
            _currentDisplay = [NSString stringWithFormat:@"%f",preDisplay.floatValue / currentDisplay.floatValue];
        }
    } else {
        _currentDisplay = currentDisplay;
    }
    
    if (_isErro) {
        _currentDisplay = @"错误";
    } else {
        _currentDisplay = [NSString stringWithFormat:@"%g",[[NSString stringDisposeWithFloatStringValue:_currentDisplay] floatValue]];
    }
}

@end
