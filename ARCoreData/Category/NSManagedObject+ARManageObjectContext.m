//
//  NSManagedObject+ARManageObjectContext.m
//  Board
//
//  Created by August on 15/3/20.
//
//

#import "NSManagedObject+ARManageObjectContext.h"
#import "ARCoreDataManager.h"

NSString *const ARCoreDataCurrentThreadContext = @"ARCoreData_CurrentThread_Context";

@implementation NSManagedObject (ARManageObjectContext)

+ (NSManagedObjectContext *)defaultPrivateContext {
    return [ARCoreDataManager shareManager].privateContext;
}

+ (NSManagedObjectContext *)defaultMainContext {
    return [ARCoreDataManager shareManager].mainContext;
}

+ (NSManagedObjectContext *)currentContext {
    if ([NSThread isMainThread]) {
        return [self defaultMainContext];
    }
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext *context = threadDict[ARCoreDataCurrentThreadContext];
    if (context == nil) {
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setParentContext:[self defaultPrivateContext]];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        threadDict[ARCoreDataCurrentThreadContext] = context;
    }
    return context;
}

@end
