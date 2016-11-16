//
//  HXSelectPhotoCountView.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXSelectPhotoCountView;

@protocol HXSelectPhotoCountViewDelegate <NSObject>

- (void)selectPhotoCountView:(HXSelectPhotoCountView *)selectPhotoCountView addButtonAction:(UIButton *)sender;

@end

@interface HXSelectPhotoCountView : UIView

@property (nonatomic,weak) id<HXSelectPhotoCountViewDelegate> delegate;
@property (nonatomic,strong) UILabel *pointsLabel;

@end
