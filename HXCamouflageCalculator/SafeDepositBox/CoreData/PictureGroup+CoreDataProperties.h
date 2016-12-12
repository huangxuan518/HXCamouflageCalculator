//
//  PictureGroup+CoreDataProperties.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 2016/12/12.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "PictureGroup+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PictureGroup (CoreDataProperties)

+ (NSFetchRequest<PictureGroup *> *)fetchRequest;

@property (nonatomic) int64_t count;
@property (nonatomic) int64_t groupId;
@property (nullable, nonatomic, retain) NSData *logoData;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *time;

@end

NS_ASSUME_NONNULL_END
