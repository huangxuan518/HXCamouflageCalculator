//
//  PictureGroupEntity.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureGroupEntity : NSObject

@property (nonatomic) int64_t groupId;
@property (nullable, nonatomic, retain) NSData *logoData;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int64_t count;

@end
