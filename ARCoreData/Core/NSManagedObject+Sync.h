//
//  NSManagedObject+Sync.h
//  Pods
//
//  Created by August on 15/6/10.
//
//

#import <CoreData/CoreData.h>
#import "ARManageObjectMappingProtocol.h"

@interface NSManagedObject (Sync)

/**
 *  sync to coreData Stack
 *
 *  @param JSONs      JSON key value objects(KVC objects)
 *  @param completion async completion block
 */
+(void)AR_syncWithJSONs:(NSArray *)JSONs completion:(void(^)(NSArray *objects))completion;
/**
 *  sync to coreData Stack
 *
 *  @param JSONs       SON key value objects(KVC objects)
 *  @param mergePolicy ARRelationshipMergePolicy custom
 *  @param completion  async completion block
 */
+(void)AR_syncWithJSONs:(NSArray *)JSONs mergePolicy:(ARRelationshipMergePolicy)mergePolicy completion:(void(^)(NSArray *objects))completion;

@end
