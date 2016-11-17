//
//  HXEditPhotoToolBar.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/17.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXEditPhotoToolBar;

@protocol HXEditPhotoToolBarDelegate <NSObject>

- (void)editPhotoCountView:(HXEditPhotoToolBar *)editPhotoCountView buttonAction:(UIButton *)sender;

@end

@interface HXEditPhotoToolBar : UIView

@property (nonatomic,weak) id<HXEditPhotoToolBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

- (void)setSelectPictureCount:(NSInteger)selectPictureCount delegate:(id)delegate;

+ (id)instanceView;

@end
