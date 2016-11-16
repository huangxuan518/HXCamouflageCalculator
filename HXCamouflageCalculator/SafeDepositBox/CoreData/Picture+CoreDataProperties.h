//
//  Picture+CoreDataProperties.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/19.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "Picture+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Picture (CoreDataProperties)

+ (NSFetchRequest<Picture *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *data;
@property (nonatomic) int64_t groupId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *time;

@end

NS_ASSUME_NONNULL_END
