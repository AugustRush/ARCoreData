//
//  NSManagedObject+ARCoreDataAdditions.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ARCoreDataAdditions)

+(NSString *)entityName;

+(id)inserNewEntityIntoContext:(NSManagedObjectContext *)context;

@end
