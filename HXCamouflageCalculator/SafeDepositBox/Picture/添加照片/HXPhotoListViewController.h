//
//  HXPhotoListViewController.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "BaseCollectionViewController.h"

@interface HXPhotoListViewController : BaseCollectionViewController

@property (nonatomic,strong) NSString *albumName;
@property (nonatomic,assign) NSInteger groupId;
@property (nonatomic,assign) NSInteger photoAlbumIndex;
@property (nonatomic,assign) int type;//0.添加照片 1.添加封面 默认添加照片

@end
