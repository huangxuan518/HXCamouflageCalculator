//
//  PictureGroup+CoreDataProperties.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 2016/12/12.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "PictureGroup+CoreDataProperties.h"

@implementation PictureGroup (CoreDataProperties)

+ (NSFetchRequest<PictureGroup *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PictureGroup"];
}

@dynamic count;
@dynamic groupId;
@dynamic logoData;
@dynamic name;
@dynamic time;

@end
