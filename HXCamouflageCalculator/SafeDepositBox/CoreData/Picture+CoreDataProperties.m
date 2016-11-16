//
//  Picture+CoreDataProperties.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/19.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "Picture+CoreDataProperties.h"

@implementation Picture (CoreDataProperties)

+ (NSFetchRequest<Picture *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Picture"];
}

@dynamic data;
@dynamic groupId;
@dynamic name;
@dynamic time;

@end
