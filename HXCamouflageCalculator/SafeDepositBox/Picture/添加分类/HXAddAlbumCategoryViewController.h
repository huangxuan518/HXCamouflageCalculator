//
//  HXAddAlbumCategoryViewController.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "BaseTableViewController.h"
#import "PictureGroupEntity.h"

#define kMaxPhotoNum 9

@interface HXAddAlbumCategoryViewController : BaseTableViewController

@property (nonatomic,strong) PictureGroupEntity *pictureGroupEntity;
@property (nonatomic,copy) void (^completion)(HXAddAlbumCategoryViewController *vc,BOOL isRefresh);

@end
