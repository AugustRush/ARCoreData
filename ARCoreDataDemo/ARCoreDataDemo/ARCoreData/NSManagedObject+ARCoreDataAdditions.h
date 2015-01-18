//
//  NSManagedObject+ARCoreDataAdditions.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

@import CoreData;

@interface NSManagedObject (ARCoreDataAdditions)

/**
 *  convinience methods get entity name
 *
 *  @return entity name
 */
+(NSString *)entityName;

/**
 *  creat an entity in mainQueue context
 *
 *  @return entity
 */
+(id)newEntityInMain;
/**
 *  creat an entity in mainQueue context
 *
 *  @return entity
 */
+(id)newEntity;

/**
 *  creat an new entity in your context
 *
 *  @param context your context
 *
 *  @return entity
 */
+(id)creatNewEntityWithContext:(NSManagedObjectContext *)context;

#pragma mark - fetch objects methods


/**
 *  fetch bjects with your NSFetchRequest
 *
 *  @param request subclass of NSFetchrequest (sync methods)
 *
 *  @return objects array
 */
+(NSArray *)objectsWithFetchRequest:(NSFetchRequest *)request;

/**
 *  fetch bjects with your NSFetchRequest
 *
 *  @param request subclass of NSFetchrequest (async methods)
 *
 *  @return objects array
 */

+(void)objectsWithFetchRequest:(NSFetchRequest *)request
                       handler:(void(^)(NSError *error, NSArray *objects))handler;


/**
 *  all objects in default context (sync methods)
 *
 *  @return all onjects
 */
+(NSArray *)allObjects;

/**
 *  all objects in defaults (async methods)
 *
 *  @param handler objects array block with error info
 */
+(void)allObjectsWithHandler:(void(^)(NSError *error, NSArray *objects))handler;

/**
 *  fetch objects with your predicate (async methods)
 *
 *  @param predicate your predicate
 *  @param handler   completion block
 */
+(void)objectsWithPredicate:(NSPredicate *)predicate
                    handler:(void(^)(NSError *error, NSArray *objects))handler;
/**
 *  fetch objects with your predicate (sync methods)
 *
 *  @param predicate your predicate
 *  @param handler   completion block
 */

+(NSArray *)objectsWithPredicate:(NSPredicate *)predicate;


+(void)objectsWhere:(NSString *)filterCondition
            handler:(void(^)(NSError *error, NSArray *objects))handler;

+(NSArray *)objectsWhere:(NSString *)filterCondition;

+(void)objectsWithSortedKey:(NSString *)key
                  ascending:(BOOL)ascending
                      limit:(NSUInteger)limit
                    handler:(void(^)(NSError *error, NSArray *objects))handler;

+(NSArray *)objectsWithSortedKey:(NSString *)key
                  ascending:(BOOL)ascending
                      limit:(NSUInteger)limit;

+(void)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
            handler:(void(^)(NSError *error, NSArray *objects))handler;

+(NSArray *)objectsWhere:(NSString *)filterCondition
          sortedUsingKey:(NSString *)key
               ascending:(BOOL)ascending;

+(void)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
          batchSize:(NSUInteger)batchSize
            handler:(void (^)(NSError *error, NSArray *objects))handler;

+(NSArray *)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
          batchSize:(NSUInteger)batchSize;

+(void)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
          batchSize:(NSUInteger)batchSize
         fetchLimit:(NSUInteger)fetchLimit
            handler:(void (^)(NSError *, NSArray *))handler;

+(NSArray *)objectsWhere:(NSString *)filterCondition
          sortedUsingKey:(NSString *)key
               ascending:(BOOL)ascending
               batchSize:(NSUInteger)batchSize
              fetchLimit:(NSUInteger)fetchLimit;

+(void)objectsWhere:(NSString *)filterCondition
     sortedUsingKey:(NSString *)key
          ascending:(BOOL)ascending
          batchSize:(NSUInteger)batchSize
         fetchLimit:(NSUInteger)fetchLimit
        fetchOffset:(NSUInteger)fetchOffset
            handler:(void (^)(NSError *, NSArray *))handler;

+(NSArray *)objectsWhere:(NSString *)filterCondition
          sortedUsingKey:(NSString *)key
               ascending:(BOOL)ascending
               batchSize:(NSUInteger)batchSize
              fetchLimit:(NSUInteger)fetchLimit
             fetchOffset:(NSUInteger)fetchOffset;


+(NSUInteger)numberOfEntitys;
+(NSUInteger)numberOfEntitysWhere:(NSString *)condition;

+(id)objectWherePrimarykey:(NSString *)key equalTo:(id)value;

// delete methods

+(void)deleteAllWithHandler:(void(^)(NSError *error))handler;

+(void)deleteWhere:(NSString *)filterConfition handler:(void(^)(NSError *error))handler;

// update methods

+(void)updateProperty:(NSString *)propertyName toValue:(id)value;

+(void)updateProperty:(NSString *)propertyName toValue:(id)value where:(NSString *)condition;

+(void)updateKeyPath:(NSString *)keyPath toValue:(id)value;

+(void)updateKeyPath:(NSString *)keyPath toValue:(id)value where:(NSString *)condition;

+(void)saveWithHandler:(void(^)(NSError *error))handler;

-(id)objectInMain;
-(id)objectInPrivate;

@end
