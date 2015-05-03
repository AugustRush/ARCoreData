//
//  NSManagedObject+ARCoreDataAdditions.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "NSManagedObject+ARConvenience.h"
#import "ARCoreDataManager.h"
#import "NSManagedObjectContext+ARAddtions.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "NSManagedObject+ARRequest.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "ARCoreDataMacros.h"

@implementation NSManagedObject (ARConvenience)

#pragma mark - update methods

+(void)AR_updateProperty:(NSString *)propertyName toValue:(id)value
{
    [self AR_updateProperty:propertyName toValue:value where:nil];
}

+(void)AR_updateProperty:(NSString *)propertyName toValue:(id)value where:(NSString *)condition
{
#ifdef _systermVersion_greter_8_0
    NSManagedObjectContext *manageOBjectContext = [self defaultPrivateContext];
    
    [manageOBjectContext performBlock:^{
        NSBatchUpdateRequest *batchRequest = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:[self AR_entityName]];
        batchRequest.propertiesToUpdate = @{propertyName:value};
        batchRequest.resultType = NSUpdatedObjectIDsResultType;
        batchRequest.affectedStores = [[manageOBjectContext persistentStoreCoordinator] persistentStores];
        if (condition) {
            batchRequest.predicate = [NSPredicate predicateWithFormat:condition];
        }
        
        NSError *requestError;
        NSBatchUpdateResult *result = (NSBatchUpdateResult *)[manageOBjectContext executeRequest:batchRequest error:&requestError];
        
        if ([[result result] respondsToSelector:@selector(count)]){
            if ([[result result] count] > 0){
                [manageOBjectContext performBlock:^{
                    for (NSManagedObjectID *objectID in [result result]){
                        NSError         *faultError = nil;
                        NSManagedObject *object     = [manageOBjectContext existingObjectWithID:objectID error:&faultError];
                        // Observers of this context will be notified to refresh this object.
                        // If it was deleted, well.... not so much.
                        [manageOBjectContext refreshObject:object mergeChanges:YES];
                    }
                    
                    NSError *error = nil;
                    [manageOBjectContext save:&error];
                    NSLog(@"%s error is %@",__PRETTY_FUNCTION__,error);
                }];
            } else {
                // We got back nothing!
            }
        } else {
            // We got back something other than a collection
        }
    }];
#else
    
    [self AR_updateKeyPath:propertyName toValue:value where:condition];
#endif
}

+(void)AR_updateKeyPath:(NSString *)keyPath toValue:(id)value
{
    [self AR_updateKeyPath:keyPath toValue:value where:nil];
}

+(void)AR_updateKeyPath:(NSString *)keyPath toValue:(id)value where:(NSString *)condition
{
    NSManagedObjectContext *manageObjectContext = [self defaultPrivateContext];
    __block NSError *error = nil;
    [manageObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self AR_entityName]];
        if (condition) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
            fetchRequest.predicate = predicate;
        }
        NSArray *allObjects = [manageObjectContext executeFetchRequest:fetchRequest error:&error];
        if (allObjects != nil) {
            [allObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
                [obj setValue:value forKey:keyPath];
            }];
            NSError *saveError = nil;
            [manageObjectContext save:&saveError];
            NSLog(@"%s save error is %@",__PRETTY_FUNCTION__,saveError);
        }else{
            NSLog(@"%s fetch error is %@",__PRETTY_FUNCTION__,error);
        }
    }];
}

#pragma mark - save methods

+(BOOL)AR_saveAndWait
{
    NSManagedObjectContext *privateContext = [self defaultPrivateContext];
    NSManagedObjectContext *mainContext = [self defaultMainContext];
    __block BOOL success = NO;
    __block NSError *error = nil;
    if ([privateContext hasChanges]) {
        [privateContext performBlockAndWait:^{
            success = [privateContext save:&error];
        }];
    }else if([mainContext hasChanges]){
        [mainContext performBlockAndWait:^{
            success = [mainContext save:&error];
        }];
    }else{
        NSLog(@"there is nothing to save !");
    }
    if (error != nil) {
        NSLog(@"save error is %@",error);
    }
    return success;
}

+(void)AR_saveAndWaitCompletion:(void (^)(BOOL, NSError *))completion
{
    NSManagedObjectContext *privateContext = [self defaultPrivateContext];
    NSManagedObjectContext *mainContext = [self defaultMainContext];
    
    __block NSError *error = nil;
    __block BOOL success = YES;
    if ([privateContext hasChanges]) {
        [privateContext performBlockAndWait:^{
            
            success = [privateContext save:&error];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success,error);
                });
            }
        }];
    }else if ([mainContext hasChanges]){
        [mainContext performBlockAndWait:^{
            success = [mainContext save:&error];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success,error);
                });
            }
        }];
    }else{
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success,error);
            });
        }
    }

}

+(void)AR_saveCompletion:(void (^)(BOOL, NSError *))completion
{
    NSManagedObjectContext *privateContext = [self defaultPrivateContext];
    NSManagedObjectContext *mainContext = [self defaultMainContext];
    
    __block NSError *error = nil;
    __block BOOL success = YES;
    if ([privateContext hasChanges]) {
        [privateContext performBlock:^{
            
            success = [privateContext save:&error];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success,error);
                });
            }
        }];
    }else if ([mainContext hasChanges]){
        [mainContext performBlock:^{
            success = [mainContext save:&error];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success,error);
                });
            }
        }];
    }else{
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success,error);
            });
        }
    }

}

#pragma mark - transfer to main/private(thread) methods

-(id)AR_objectInMain
{
    NSManagedObjectContext *mainContext = [[self class] defaultMainContext];
    if ([self.managedObjectContext isEqual:mainContext]) {
        return self;
    }else{
        return [mainContext objectWithID:self.objectID];
    }
}

-(id)AR_objectInPrivate
{
    NSManagedObjectContext *privateContext = [[self class] defaultPrivateContext];
    if ([self.managedObjectContext isEqual:privateContext]) {
        return self;
    }else{
        return [privateContext objectWithID:self.objectID];
    }
}

#pragma mark - delete methods

+(BOOL)AR_truncateAll
{
    NSFetchRequest *request = [self AR_allRequest];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    
    NSManagedObjectContext *context = [self defaultPrivateContext];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *objsToDelete = [context executeFetchRequest:request error:&error];
        for (id obj in objsToDelete ) {
            [context deleteObject:obj];
        }
    }];
    return YES;
}

-(void)AR_delete
{
    [self.managedObjectContext deleteObject:self];
}

#pragma mark - fetch methods

+(id)AR_anyone
{
    return [self AR_anyoneWithPredicate:nil];
}

+(NSArray *)AR_all
{
    return [self AR_allWithPredicate:nil];
}

+(void)AR_allWithHandler:(void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self AR_allRequest];
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block NSError *error = nil;
#ifdef _systermVersion_greter_8_0
    [context performBlock:^{
        NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(error,[result.finalResult copy]);
                }
            });
        }];
        [context executeRequest:asyncRequest error:&error];
    }];
#else
    [context performBlock:^{
        NSArray *results = [context executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(error,results);
            }
        });
    }];
#endif
}

+(NSArray *)AR_whereProperty:(NSString *)property equalTo:(id)value
{
    return [self AR_whereProperty:property equalTo:value sortedKeyPath:nil ascending:NO];
}

+(void)AR_whereProperty:(NSString *)property equalTo:(id)value handler:(void (^)(NSError *, NSArray *))handler
{
    return [self AR_whereProperty:property equalTo:value sortedKeyPath:nil ascending:NO handler:handler];
}

+(id)AR_firstWhereProperty:(NSString *)property equalTo:(id)value
{
    NSFetchRequest *request = [self AR_requestWithFetchLimit:1 batchSize:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSArray *objs = [context executeFetchRequest:request error:nil];
        if (objs.count > 0) {
            obj = objs[0];
        }
    }];  
    return obj;
}

+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value
               sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending {
    return [self AR_whereProperty:property
                          equalTo:value
                    sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:0
                       fetchLimit:0
                      fetchOffset:0];
}

+(void)AR_whereProperty:(NSString *)property
                equalTo:(id)value
          sortedKeyPath:(NSString *)keyPath
              ascending:(BOOL)ascending
                handler:(void (^)(NSError *, NSArray *))handler {
    return [self AR_whereProperty:property
                          equalTo:value
                    sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:0
                       fetchLimit:0
                      fetchOffset:0
                          handler:handler];
}


+(NSArray *)AR_allWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self AR_allRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;

}

+(id)AR_anyoneWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self AR_anyoneRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        obj = [[context executeFetchRequest:request error:&error] lastObject];
    }];
    return obj;
}

+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value
               sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
              fetchBatchSize:(NSUInteger)batchSize
                  fetchLimit:(NSUInteger)fetchLimit
                 fetchOffset:(NSUInteger)fetchOffset
{
    return [self AR_sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:batchSize
                       fetchLimit:fetchLimit
                      fetchOffset:fetchOffset
                            where:@"%K == %@",property,value];
}

+(void)AR_whereProperty:(NSString *)property
                equalTo:(id)value
          sortedKeyPath:(NSString *)keyPath
              ascending:(BOOL)ascending
         fetchBatchSize:(NSUInteger)batchSize
             fetchLimit:(NSUInteger)fetchLimit
            fetchOffset:(NSUInteger)fetchOffset
                handler:(void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self AR_requestWithFetchLimit:fetchLimit batchSize:batchSize fetchOffset:fetchOffset];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    [context performBlock:^{
        NSError *error = nil;
        NSArray *objs = [context executeFetchRequest:request error:&error];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error,objs);
            });
        }
    }];
}

+(NSArray *)AR_where:(NSString *)condition, ...
{
    NSFetchRequest *request = [self AR_allRequest];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

+(NSArray *)AR_sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
                   batchSize:(NSUInteger)batchSize
                       where:(NSString *)condition, ...
{
    NSFetchRequest *request = [self AR_requestWithFetchLimit:0
                                                   batchSize:batchSize];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;

}

+(NSArray *)AR_sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
              fetchBatchSize:(NSUInteger)batchSize
                  fetchLimit:(NSUInteger)fetchLimit
                 fetchOffset:(NSUInteger)fetchOffset
                       where:(NSString *)condition, ...
{
    NSFetchRequest *request = [self AR_requestWithFetchLimit:fetchLimit
                                                   batchSize:batchSize
                                                 fetchOffset:fetchOffset];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self defaultPrivateContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

+(NSUInteger)AR_count
{
    return [self AR_countWhere:nil];
}

+(NSUInteger)AR_countWhere:(NSString *)condition, ...
{
    NSManagedObjectContext *manageObjectContext = [self defaultPrivateContext];
    __block NSInteger count = 0;
    NSFetchRequest *request = [self AR_allRequest];
    request.resultType = NSCountResultType;
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    if (condition) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
        request.predicate = predicate;
    }
    [manageObjectContext performBlockAndWait:^{
        NSError *err;
        count = [manageObjectContext countForFetchRequest:request error:&err];
    }];
    
    return count;
}

@end
