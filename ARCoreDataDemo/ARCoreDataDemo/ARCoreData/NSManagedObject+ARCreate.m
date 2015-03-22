//
//  NSManagedObject+ARCreate.m
//  Board
//
//  Created by August on 15/3/18.
//
//

#import "NSManagedObject+ARCreate.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "NSManagedObject+ARRequest.h"

@implementation NSManagedObject (ARCreate)

+(id)AR_newInMain
{
    NSManagedObjectContext *manageContext = [self defaultMainContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self AR_entityName] inManagedObjectContext:manageContext];
}

+(id)AR_new
{
    NSManagedObjectContext *manageContext = [self defaultPrivateContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self AR_entityName] inManagedObjectContext:manageContext];
}

+(id)AR_newInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self AR_entityName] inManagedObjectContext:context];
}


@end
