//
//  CoreDataManager.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/12.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <Foundation/Foundation.h>

//XcdatamodeldName名称
static NSString *const XcdatamodeldName = @"Model";
// 数据库名称
static NSString *const CoreDataSQLiteName = @"MyCoreData.sqlite";

@interface CoreDataManager : NSObject

+ (CoreDataManager *)sharedInstance;

#pragma mark - Picture表操作 增改删查

- (void)insertPictureAry:(NSArray *)pictureAry;
- (NSArray *)selectAlbumCategoryPictureListWithGroupId:(NSInteger)groupId;
- (void)deletePictureWithPictureId:(NSInteger)pictureId;//根据pictureId删除指定图片

#pragma mark - PictureGroup表操作 增改删查

- (void)insertAlbumCategoryWithName:(NSString *)albumName coverImageData:(NSData *)coverImageData;
- (void)updateAlbumCategoryWithGroupId:(NSInteger)groupId name:(NSString *)albumName coverImageData:(NSData *)coverImageData count:(NSString *)count;
- (void)deleteAlbumCategoryWithGroupId:(NSInteger)groupId;
- (NSArray *)selectAllAlbumCategory;

#define kCoreDataManager [CoreDataManager sharedInstance]

@end
