//
//  HXAlbumNameCell.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "BaseTableViewCell.h"

@class HXAlbumNameCell;

@protocol HXAlbumNameCellDelegate <NSObject>

- (void)currencyFirstCell:(HXAlbumNameCell *)cell textField:(UITextField *)textField;

@end

@interface HXAlbumNameCell : BaseTableViewCell

@property (nonatomic,weak) id<HXAlbumNameCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;//输入框

@end
