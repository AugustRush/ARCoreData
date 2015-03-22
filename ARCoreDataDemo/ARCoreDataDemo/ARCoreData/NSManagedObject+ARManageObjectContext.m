//
//  NSManagedObject+ARManageObjectContext.m
//  Board
//
//  Created by August on 15/3/20.
//
//

#import "NSManagedObject+ARManageObjectContext.h"
#import "ARCoreDataManager.h"

@implementation NSManagedObject (ARManageObjectContext)

+(NSManagedObjectContext *)defaultPrivateContext
{
    return [ARCoreDataManager shareManager].privateContext;
}

+(NSManagedObjectContext *)defaultMainContext
{
    return [ARCoreDataManager shareManager].mainContext;
}

@end
