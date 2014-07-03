//
//  NSManagedObject+ARCoreDataAdditions.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "NSManagedObject+ARCoreDataAdditions.h"

@implementation NSManagedObject (ARCoreDataAdditions)

+(NSString *)entityName
{
    return NSStringFromClass(self);
}

+(id)inserNewEntityIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
