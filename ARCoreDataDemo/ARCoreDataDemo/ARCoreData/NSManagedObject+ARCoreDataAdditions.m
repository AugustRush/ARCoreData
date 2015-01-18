//
//  NSManagedObject+ARCoreDataAdditions.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "NSManagedObject+ARCoreDataAdditions.h"
#import "ARCoreDataPersistanceController.h"
#import "NSManagedObjectContext+ARAddtions.h"

#define _systermVersion_greter_8_0 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

@implementation NSManagedObject (ARCoreDataAdditions)

+(NSString *)entityName
{
    return NSStringFromClass(self);
}

+(id)newEntityInMain
{
    NSManagedObjectContext *manageContext = [self mainManageObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:manageContext];
}

+(id)newEntity
{
    NSManagedObjectContext *manageContext = [self manageObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:manageContext];
}

+(id)creatNewEntityWithContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+(void)objectsWithFetchRequest:(NSFetchRequest *)request handler:(void (^)(NSError *, NSArray *))handler
{
    NSManagedObjectContext *manageObjectContext = [self manageObjectContext];
    __block NSError *error = nil;
    [manageObjectContext performBlock:^{
        
#ifdef _systermVersion_greter_8_0
        NSAsynchronousFetchRequest *asyncFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult *result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error,result.finalResult);
            });
        }];
        
        [manageObjectContext executeRequest:asyncFetchRequest error:&error];
        if (error) {
            NSLog(@"error is %@",error);
        }
#else
        NSArray *objects = [manageObjectContext executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(error,objects);
        });

#endif
    }];
}

+(NSArray *)objectsWithFetchRequest:(NSFetchRequest *)request
{
    NSManagedObjectContext *manageObjectContext = [self manageObjectContext];
    __block NSError *error = nil;
    __block NSArray *objects = nil;
    [manageObjectContext performBlockAndWait:^{
        objects = [manageObjectContext executeFetchRequest:request error:&error];
    }];
    return objects;
}

+(void)allObjectsWithHandler:(void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *fetchrequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    return [self objectsWithFetchRequest:fetchrequest handler:handler];
}

+(NSArray *)allObjects
{
    return [self objectsWhere:nil];
}

+(void)objectsWithPredicate:(NSPredicate *)predicate handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:nil handler:handler];
}

+(NSArray *)objectsWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchrequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    if (predicate) {
        fetchrequest.predicate = predicate;
    }
    return [self objectsWithFetchRequest:fetchrequest];
}

+(void)objectsWhere:(NSString *)filterCondition handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:filterCondition sortedUsingKey:nil ascending:YES handler:handler];
}

+(NSArray *)objectsWhere:(NSString *)filterCondition
{
    return [self objectsWhere:filterCondition sortedUsingKey:nil ascending:YES];
}

+(void)objectsWithSortedKey:(NSString *)key ascending:(BOOL)ascending limit:(NSUInteger)limit handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:nil sortedUsingKey:key ascending:ascending batchSize:0 fetchLimit:limit fetchOffset:0 handler:handler];
}

+(NSArray *)objectsWithSortedKey:(NSString *)key ascending:(BOOL)ascending limit:(NSUInteger)limit
{
    return [self objectsWhere:nil sortedUsingKey:key ascending:ascending batchSize:0 fetchLimit:limit fetchOffset:0];
}

+(void)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:filterCondition sortedUsingKey:key ascending:ascending batchSize:0 handler:handler];
}

+(NSArray *)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending
{
    return [self objectsWhere:filterCondition sortedUsingKey:key ascending:ascending batchSize:0];
}

+(void)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending batchSize:(NSUInteger)batchSize handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:filterCondition sortedUsingKey:key ascending:ascending batchSize:batchSize fetchLimit:0 handler:handler];
}

+(NSArray *)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending batchSize:(NSUInteger)batchSize
{
    return [self objectsWhere:filterCondition sortedUsingKey:key ascending:ascending batchSize:batchSize fetchLimit:0];
}

+(void)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending batchSize:(NSUInteger)batchSize fetchLimit:(NSUInteger)fetchLimit handler:(void (^)(NSError *, NSArray *))handler
{
    return [self objectsWhere:filterCondition sortedUsingKey:key ascending:ascending batchSize:batchSize fetchLimit:fetchLimit fetchOffset:0 handler:handler];
}

+(NSArray *)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending batchSize:(NSUInteger)batchSize fetchLimit:(NSUInteger)fetchLimit
{
    return [self objectsWhere:filterCondition
               sortedUsingKey:key
                    ascending:ascending
                    batchSize:batchSize
                   fetchLimit:fetchLimit
                  fetchOffset:0];
}

+(void)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
          batchSize:(NSUInteger)batchSize
         fetchLimit:(NSUInteger)fetchLimit
        fetchOffset:(NSUInteger)fetchOffset
            handler:(void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *fetchrequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    if (filterCondition) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:filterCondition];
        fetchrequest.predicate = predicate;
    }
    if (key) {
        NSSortDescriptor *sortedDes = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
        fetchrequest.sortDescriptors = @[sortedDes];
    }
    fetchrequest.fetchBatchSize = batchSize;
    fetchrequest.fetchLimit = fetchLimit;
    fetchrequest.fetchOffset = fetchOffset;
    return [self objectsWithFetchRequest:fetchrequest handler:handler];
}

+(NSArray *)objectsWhere:(NSString *)filterCondition sortedUsingKey:(NSString *)key ascending:(BOOL)ascending batchSize:(NSUInteger)batchSize fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset
{
    NSFetchRequest *fetchrequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    if (filterCondition) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:filterCondition];
        fetchrequest.predicate = predicate;
    }
    if (key) {
        NSSortDescriptor *sortedDes = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
        fetchrequest.sortDescriptors = @[sortedDes];
    }
    fetchrequest.fetchBatchSize = batchSize;
    fetchrequest.fetchLimit = fetchLimit;
    fetchrequest.fetchOffset = fetchOffset;
    return [self objectsWithFetchRequest:fetchrequest];
}

+(void)deleteAllWithHandler:(void (^)(NSError *))handler
{
    NSManagedObjectContext *manageContext = [self manageObjectContext];
    
    [manageContext performBlock:^{
        NSArray *allObjects = [self allObjects];
        [allObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
           [manageContext deleteObject:obj];
        }];
        
        [self saveWithHandler:handler];
    }];
}

+(void)deleteWhere:(NSString *)filterConfition handler:(void (^)(NSError *))handler
{
    NSManagedObjectContext *manageContext = [self manageObjectContext];
    [manageContext performBlock:^{
        NSArray *objects = [self objectsWhere:filterConfition];
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [manageContext deleteObject:obj];
        }];
        [self saveWithHandler:handler];
    }];
}

+(void)updateProperty:(NSString *)propertyName toValue:(id)value
{
    [self updateProperty:propertyName toValue:value where:nil];
}

+(void)updateProperty:(NSString *)propertyName toValue:(id)value where:(NSString *)condition
{
#ifdef _systermVersion_greter_8_0
    NSManagedObjectContext *manageOBjectContext = [self manageObjectContext];
    
    [manageOBjectContext performBlock:^{
        NSBatchUpdateRequest *batchRequest = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:[self entityName]];
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
    
    [self updateKeyPath:propertyName toValue:value where:condition];
#endif
}

+(void)updateKeyPath:(NSString *)keyPath toValue:(id)value
{
    [self updateKeyPath:keyPath toValue:value where:nil];
}

+(void)updateKeyPath:(NSString *)keyPath toValue:(id)value where:(NSString *)condition
{
    NSManagedObjectContext *manageObjectContext = [self manageObjectContext];
    __block NSError *error = nil;
    [manageObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
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

+(NSUInteger)numberOfEntitys
{
    return [self numberOfEntitysWhere:nil];
}

+(NSUInteger)numberOfEntitysWhere:(NSString *)condition
{
    NSManagedObjectContext *manageObjectContext = [self manageObjectContext];
    __block NSInteger count = 0;
    [manageObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
        request.resultType = NSManagedObjectIDResultType;
        if (condition) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
            request.predicate = predicate;
        }
        [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
        
        NSError *err;
        count = [manageObjectContext countForFetchRequest:request error:&err];
    }];
    
    return count;
}

+(id)objectWherePrimarykey:(NSString *)key equalTo:(id)value
{
    NSManagedObjectContext *manageObjectContext = [self manageObjectContext];
    __block NSManagedObject *obj = nil;
    [manageObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
        NSString *condition = [NSString stringWithFormat:@"%@ = %@",key,value];
        NSPredicate *predicatre = [NSPredicate predicateWithFormat:condition];
        fetchRequest.predicate = predicatre;
        NSError *error = nil;
        NSArray *results = [manageObjectContext executeFetchRequest:fetchRequest error:&error];
        if (results.count == 1) {
            obj = results[0];
        }else{
            NSLog(@"primary key object should be only one, error is %@",error);
        }
    }];
    
    return obj;
}

+(void)saveWithHandler:(void (^)(NSError *))handler
{
    NSManagedObjectContext *privateContext = [self manageObjectContext];
    NSManagedObjectContext *mainContext = [self mainManageObjectContext];
    
    __block NSError *error = nil;
    if ([privateContext hasChanges]) {
        [privateContext performBlockAndWait:^{
            
            [privateContext save:&error];
            handler(error);
        }];
    }else if ([mainContext hasChanges]){
        [mainContext performBlockAndWait:^{
            [mainContext save:&error];
            handler(error);
        }];
    }
}

-(id)objectInMain
{
    NSManagedObjectContext *mainContext = [[self class] mainManageObjectContext];
    if ([self.managedObjectContext isEqual:mainContext]) {
        return self;
    }else{
        return [mainContext objectWithID:self.objectID];
    }
}

-(id)objectInPrivate
{
    NSManagedObjectContext *privateContext = [[self class] manageObjectContext];
    if ([self.managedObjectContext isEqual:privateContext]) {
        return self;
    }else{
        return [privateContext objectWithID:self.objectID];
    }
}

#pragma mark - private methods

+(NSManagedObjectContext *)manageObjectContext
{
    return [[ARCoreDataPersistanceController sharePersistanceController] managedObjectContext];
}

+(NSManagedObjectContext *)mainManageObjectContext
{
    return [[ARCoreDataPersistanceController sharePersistanceController] mainManageObjectContext];
}

@end
