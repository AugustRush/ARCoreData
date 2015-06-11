//
//  NSManagedObject+Sync.m
//  Pods
//
//  Created by August on 15/6/10.
//
//

#import "NSManagedObject+Sync.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "NSManagedObject+ARRequest.h"
#import "NSManagedObject+ARMapping.h"
#import "NSManagedObject+ARCreate.h"

@implementation NSManagedObject (Sync)

+(id)AR_syncWithJSON:(id)JSON
{
    return [self AR_syncWithJSON:JSON mergePolicy:ARRelationshipMergePolicyAdd];
}

+(id)AR_syncWithJSON:(id)JSON mergePolicy:(ARRelationshipMergePolicy)mergePolicy
{
    NSAssert(JSON != nil, @"JSON object shoud not be nil");
    return [[self AR_syncWithJSONs:@[JSON] mergePolicy:mergePolicy] lastObject];
}

+(NSArray *)AR_syncWithJSONs:(NSArray *)JSONs
{
    return [self AR_syncWithJSONs:JSONs mergePolicy:ARRelationshipMergePolicyAdd];
}

+(NSArray *)AR_syncWithJSONs:(NSArray *)JSONs mergePolicy:(ARRelationshipMergePolicy)mergePolicy
{
    NSAssert([JSONs isKindOfClass:[NSArray class]], @"JSONs should be a NSArray");
    NSAssert1([self respondsToSelector:@selector(JSONKeyPathsByPropertyKey)],  @"%@ class should impliment +(NSDictionary *)JSONKeyPathsByPropertyKey; method", NSStringFromClass(self));
    NSMutableArray *objects = [NSMutableArray array];
    
    NSDictionary *mapping = [self performSelector:@selector(JSONKeyPathsByPropertyKey)];
    NSSet *primaryKeys = nil;
    if ([self respondsToSelector:@selector(uniquedPropertyKeys)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        primaryKeys = [self performSelector:@selector(uniquedPropertyKeys)];
#pragma clang diagnostic pop
    }
    
    NSManagedObjectContext *context = [self defaultPrivateContext];
    for (id json in JSONs) {
        [context performBlockAndWait:^{
            [objects addObject:[self objectWithObject:json
                                          primaryKeys:primaryKeys
                                              mapping:mapping
                              relationshipMergePolicy:mergePolicy
                                            inContext:context]];
        }];
    }

    return objects;
}

+(id)     objectWithObject:(id)JSON
               primaryKeys:(NSSet *)primaryKeys
                   mapping:(NSDictionary *)mapping
   relationshipMergePolicy:(ARRelationshipMergePolicy)policy
                 inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *entity = nil;
    @autoreleasepool {
        // find or create the entity object
        if (primaryKeys == nil || primaryKeys.count == 0) {
            entity = [self AR_newInContext:context];
        }else{
            
            //create a compumd predicate
            NSString *entityName = [self AR_entityName];
            NSMutableArray *subPredicates = [NSMutableArray array];
            for (NSString *primaryKey in primaryKeys) {
                NSString *mappingKey = [mapping valueForKey:primaryKey];
                
                NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName] objectForKey:primaryKey];
                id remoteValue = [JSON valueForKeyPath:mappingKey];
                if (attributeDes.attributeType == NSStringAttributeType) {
                    remoteValue = [remoteValue description];
                }else{
                    remoteValue = [NSNumber numberWithLongLong:[remoteValue longLongValue]];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",primaryKey,remoteValue];
                [subPredicates addObject:predicate];
            }
            
            NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
            NSString *objectIDStoreKey = [entityName stringByAppendingString:compoundPredicate.predicateFormat];
            NSManagedObjectID *objectID = [[self objectIDsCache] objectForKey:objectIDStoreKey];
            if (objectID != nil) {
                entity = [context existingObjectWithID:objectID error:nil];
            }
            
            if (entity == nil) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self AR_entityName]];
                fetchRequest.fetchLimit = 1;
                [fetchRequest setPredicate:compoundPredicate];
                
                entity = [[context executeFetchRequest:fetchRequest error:nil] lastObject];
                
                
                if (entity == nil) {
                    entity = [self AR_newInContext:context];
                    [[self objectIDsCache] setObject:[entity.objectID copy] forKey:objectIDStoreKey];
                }
            }
        }
        
        NSArray *attributes = [entity allAttributeNames];
        NSArray *relationships = [entity allRelationshipNames];
        
        [mapping enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            
            NSString *methodName = [NSString stringWithFormat:@"%@Transformer:",key];
            SEL selector = NSSelectorFromString(methodName);
            
            if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id value = [self performSelector:selector withObject:[JSON valueForKeyPath:obj]];
#pragma clang diagnostic pop
                if (value != nil) {
                    [entity setValue:value forKey:key];
                }
                
            }else{
                if ([attributes containsObject:key]) {
                    [entity mergeAttributeForKey:key withValue:[JSON valueForKeyPath:obj]];
                    
                    
                }else if ([relationships containsObject:key]){
                    [entity mergeRelationshipForKey:key withValue:[JSON valueForKeyPath:obj] mergePolicy:policy];
                }
                
            }
            
        }];
    }
    return entity;
}

#pragma mark - private methods

+(NSCache *)objectIDsCache
{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

@end
