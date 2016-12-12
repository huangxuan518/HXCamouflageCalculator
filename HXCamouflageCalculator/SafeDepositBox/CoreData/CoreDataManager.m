//
//  CoreDataManager.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/12.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Picture+CoreDataProperties.h"
#import "PictureGroup+CoreDataProperties.h"

#import "PictureEntity.h"
#import "PictureGroupEntity.h"

#define kPictureTableName @"Picture"
#define kPictureGroupTableName @"PictureGroup"

@interface CoreDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext; //管理对象，上下文，持久性存储模型对象
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel; //被管理的数据模型，数据结构
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;//连接数据库的

@end

@implementation CoreDataManager

+ (CoreDataManager *)sharedInstance {
    
    static CoreDataManager * _sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CoreDataManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

//.获取Documents路径
- (NSURL *)applicationDocumentsDirectory {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"%@",url);
    return url;
}

#pragma mark - Core Data stack

//管理对象，上下文，持久性存储模型对象
- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

//被管理的数据模型，数据结构
- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:XcdatamodeldName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

//连接数据库的
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:CoreDataSQLiteName];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Picture表操作

//批量插入图片
- (void)insertPictureAry:(NSArray *)pictureAry {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    __block NSInteger groupId = 0;
    
    [pictureAry enumerateObjectsUsingBlock:^(PictureEntity *pictureEntity, NSUInteger idx, BOOL * _Nonnull stop) {
        Picture *picture = [NSEntityDescription insertNewObjectForEntityForName:kPictureTableName inManagedObjectContext:context];
        //为了使图片分类ID不重复，我们采取当前时间戳作为ID进行存储
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *pictureId = [NSString stringWithFormat:@"%@%lu",dateString,(unsigned long)idx];
        picture.pictureId = pictureId.integerValue;
        picture.data = pictureEntity.data;
        picture.groupId = pictureEntity.groupId;
        picture.name = pictureEntity.name;
        picture.time = pictureEntity.time;
        
        groupId = pictureEntity.groupId;
    }];

    [self saveContext];
    
    //查询当前类下面的图片数量
    [self selectAlbumCategoryPictureListWithGroupId:groupId];
}

//查询分类下面图片
- (NSArray *)selectAlbumCategoryPictureListWithGroupId:(NSInteger)groupId {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //查询条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%ld",(long)groupId]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kPictureTableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *resultArray = [NSMutableArray new];
    
    for (Picture *picture in array) {
        PictureEntity *pictureEntity = [PictureEntity new];
        pictureEntity.pictureId = picture.pictureId;
        pictureEntity.groupId = picture.groupId;
        pictureEntity.data = picture.data;
        pictureEntity.name = picture.name;
        pictureEntity.time = picture.time;
        [resultArray addObject:pictureEntity];
    }
    
    //更新数量
    [self updateAlbumCategoryWithGroupId:groupId name:nil coverImageData:nil count:[NSString stringWithFormat:@"%lu",(unsigned long)resultArray.count]];
    
    return resultArray;
}

//根据pictureId删除指定图片
- (void)deletePictureWithPictureId:(NSInteger)pictureId {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kPictureTableName inManagedObjectContext:context]];
    
    //删除谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"pictureId==%ld",(long)pictureId]];
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    
    [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [context deleteObject:obj];
    }];
    
    [self saveContext];
}

//删除分类下面所有图片
- (void)deleteAllAlbumCategoryPictureWithGroupIdId:(NSInteger)groupId {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kPictureTableName inManagedObjectContext:context]];
    
    //删除谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%ld",(long)groupId]];
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    
    [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [context deleteObject:obj];
    }];
    
    [self saveContext];
}

#pragma mark - PictureGroup表操作

//插入数据
- (void)insertAlbumCategoryWithName:(NSString *)albumName coverImageData:(NSData *)coverImageData {
        
    NSManagedObjectContext *context = self.managedObjectContext;

    PictureGroup *pictureGroup = [NSEntityDescription insertNewObjectForEntityForName:kPictureGroupTableName inManagedObjectContext:context];
    //为了使图片分类ID不重复，我们采取当前时间戳作为ID进行存储
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    [pictureGroup setGroupId:dateString.integerValue];
    [pictureGroup setName:albumName];
    [pictureGroup setLogoData:coverImageData];
    [pictureGroup setTime:[NSDate date]];
    [pictureGroup setCount:0];

    [self saveContext];
}

//查询
- (NSArray *)selectAllAlbumCategory {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kPictureGroupTableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *resultArray = [NSMutableArray new];
    
    for (PictureGroup *pictureGroup in array) {
        PictureGroupEntity *pictureGroupEntity = [PictureGroupEntity new];
        pictureGroupEntity.groupId = pictureGroup.groupId;
        pictureGroupEntity.logoData = pictureGroup.logoData;
        pictureGroupEntity.name = pictureGroup.name;
        pictureGroupEntity.time = pictureGroup.time;
        pictureGroupEntity.count = pictureGroup.count;
        [resultArray addObject:pictureGroupEntity];
    }
    return resultArray;
}

//根据groupId删除指定相册分类
- (void)deleteAlbumCategoryWithGroupId:(NSInteger)groupId {
    NSManagedObjectContext *context = self.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kPictureGroupTableName inManagedObjectContext:context]];
    
    //删除谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%ld",(long)groupId]];
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    
    [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [context deleteObject:obj];
    }];
    
    [self saveContext];
    
    //管理图片删除
    [self deleteAllAlbumCategoryPictureWithGroupIdId:groupId];
}

//更新分类
- (void)updateAlbumCategoryWithGroupId:(NSInteger)groupId name:(NSString *)albumName coverImageData:(NSData *)coverImageData count:(NSString *)count {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kPictureGroupTableName inManagedObjectContext:context]];
    
    //删除谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%ld",(long)groupId]];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    
    for (PictureGroup *pictureGroup in result) {
        if (albumName.length > 0) {
            pictureGroup.name = albumName;
        }
        if (coverImageData) {
            pictureGroup.logoData = coverImageData;
        }
        if (count.length > 0) {
            pictureGroup.count = count.integerValue;
        }
    }
    
    [self saveContext];
}

@end
