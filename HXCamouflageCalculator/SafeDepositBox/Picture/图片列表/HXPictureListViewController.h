//
//  HXPictureListViewController.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "BaseCollectionViewController.h"
#import "PictureGroupEntity.h"

@interface HXPictureListViewController : BaseCollectionViewController

@property (nonatomic,strong) PictureGroupEntity *pictureGroupEntity;
@property (nonatomic,copy) void (^completion)(HXPictureListViewController *vc,BOOL isRefresh);

//添加照片完成
- (void)addPhotoCompletion:(NSArray *)ary;

@end
