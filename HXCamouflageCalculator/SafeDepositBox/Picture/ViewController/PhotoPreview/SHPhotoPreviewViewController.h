//
//  SHPhotoPreviewViewController.h
//  DDMMerchant
//
//  Created by Love on 16/5/10.
//  Copyright © 2016年 YISS. All rights reserved.
//

#import "BaseViewController.h"

@interface SHPhotoPreviewViewController : BaseViewController

@property (nonatomic,copy) NSString *superTitle;

//删除照片
@property (nonatomic,copy) void (^deleteCompletion)(SHPhotoPreviewViewController *vc, NSArray *photos,id currentDeleteImage);

/**
 *  初始化
 *
 *  @param photos 需要显示的照片，可以是ALAsset或者UIImage
 *  @param index  显示第几张 index 防止越界
 *
 *  @return
 */
- (instancetype)initWithPhotos:(NSArray *)photos index:(NSInteger)index;

@end
