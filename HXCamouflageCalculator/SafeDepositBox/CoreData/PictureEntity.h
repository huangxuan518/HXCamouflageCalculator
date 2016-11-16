//
//  PictureEntity.h
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureEntity : NSObject

@property (nullable, nonatomic, retain) NSData *data;
@property (nonatomic) int64_t groupId;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *time;

@end
