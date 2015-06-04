//
//  NSManagedObject+ARCoreDataAdditions.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

@import CoreData;

@interface NSManagedObject (ARConvenience)

/**
 *  find a local object
 *
 *  @return the anyone object
 */
+(id)AR_anyone;
/**
 *  sync find all objects
 *
 *  @return all local objects
 */
+(NSArray *)AR_all;
/**
 *  async find all objects
 *
 *  @param handler finished handler block
 */
+(void)AR_allWithHandler:(void(^)(NSError *error, NSArray *objects))handler;
/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return all objects fit in this condition
 */
+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value;
/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property property name
 *  @param value    expect value
 *  @param handler  finished handler block
 */
+(void)AR_whereProperty:(NSString *)property
                equalTo:(id)value
                handler:(void(^)(NSError *error, NSArray *objects))handler;
/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return an object fit in this condition
 */
+(id)AR_firstWhereProperty:(NSString *)property
                   equalTo:(id)value;
/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     expect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *
 *  @return objects fit in this condition
 */
+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value
               sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending;
/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property property name
 *  @param value    expect value
 *  @param keyPath  keypath
 *  @param ascendng ascending
 *  @param handler  finished fetch block
 */
+(void)AR_whereProperty:(NSString *)property
                equalTo:(id)value
          sortedKeyPath:(NSString *)keyPath
              ascending:(BOOL)ascending
                handler:(void (^)(NSError *, NSArray *))handler;
/**
 *  find all objects fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return all objects fit this predicate
 */
+(NSArray *)AR_allWithPredicate:(NSPredicate *)predicate;
/**
 *  find an object fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return an objects fit this predicate
 */
+(id)AR_anyoneWithPredicate:(NSPredicate *)predicate;

/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *
 *  @return objects fit in this condition
 */
+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value
               sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
              fetchBatchSize:(NSUInteger)batchSize
                  fetchLimit:(NSUInteger)fetchLimit
                 fetchOffset:(NSUInteger)fetchOffset;
/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *  @param handler    finished fetch handler block
 */
+(void)AR_whereProperty:(NSString *)property
                equalTo:(id)value
          sortedKeyPath:(NSString *)keyPath
              ascending:(BOOL)ascending
         fetchBatchSize:(NSUInteger)batchSize
             fetchLimit:(NSUInteger)fetchLimit
            fetchOffset:(NSUInteger)fetchOffset
                handler:(void(^)(NSError *error, NSArray *objects))handler;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param condition like [NSString stringWithFormat:]
 *
 *  @return objects fit this condition
 */
+(NSArray *)AR_where:(NSString *)condition,...;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+(NSArray *)AR_sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
                   batchSize:(NSUInteger)batchSize
                       where:(NSString *)condition,...;

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param batchSize   perform fetch batch size
 *  @param fetchLimit  max count of objects one time to fetch
 *  @param fetchOffset fetch offset
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+(NSArray *)AR_sortedKeyPath:(NSString *)keyPath
                   ascending:(BOOL)ascending
              fetchBatchSize:(NSUInteger)batchSize
                  fetchLimit:(NSUInteger)fetchLimit
                 fetchOffset:(NSUInteger)fetchOffset
                       where:(NSString *)condition,...;

/**
 *  fetch count of all objects
 *
 *  @return the entity's count
 */
+(NSUInteger)AR_count;
/**
 *  fetch count of all objects in this condition
 *
 *  @param condition filter condition
 *
 *  @return count of objects
 */
+(NSUInteger)AR_countWhere:(NSString *)condition,...;

// delete methods

+(BOOL)AR_truncateAll;
-(void)AR_delete;

//save methods
+(BOOL)AR_saveAndWait;
+(void)AR_saveAndWaitCompletion:(void(^)(BOOL success,NSError *error))completion;
+(void)AR_saveCompletion:(void(^)(BOOL success, NSError *error))completion;

// update methods

+(void)AR_updateProperty:(NSString *)propertyName toValue:(id)value;
+(void)AR_updateProperty:(NSString *)propertyName toValue:(id)value where:(NSString *)condition;
+(void)AR_updateKeyPath:(NSString *)keyPath toValue:(id)value;
+(void)AR_updateKeyPath:(NSString *)keyPath toValue:(id)value where:(NSString *)condition;


-(id)AR_objectInMain;
-(id)AR_objectInPrivate;

@end
