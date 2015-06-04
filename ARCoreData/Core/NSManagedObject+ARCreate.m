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
#import "NSManagedObject+ARMapping.h"

@implementation NSManagedObject (ARCreate)

#pragma mark - common create

+(id)AR_new
{
    NSManagedObjectContext *manageContext = [self defaultPrivateContext];
    return [NSEntityDescription insertNewObjectForEntityForName:[self AR_entityName] inManagedObjectContext:manageContext];
}

+(id)AR_newInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self AR_entityName] inManagedObjectContext:context];
}

+(NSCache *)objectIDStore
{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

#pragma mark - ARManageObjectMappingProtocol create

+(id)AR_newOrUpdateWithJSON:(NSDictionary *)JSON
{
    return [self AR_newOrUpdateWithJSON:JSON relationshipMergePolicy:ARRelationshipMergePolicyAdd];
}

+(id)AR_newOrUpdateWithJSON:(NSDictionary *)JSON relationshipMergePolicy:(ARRelationshipMergePolicy)policy
{
    if (JSON != nil) {
        return [[self AR_newOrUpdateWithJSONs:@[JSON] relationshipsMergePolicy:policy] lastObject];
    }
    return nil;
}

+(NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs
{
    return [self AR_newOrUpdateWithJSONs:JSONs relationshipsMergePolicy:ARRelationshipMergePolicyAdd];
}

+(NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs relationshipsMergePolicy:(ARRelationshipMergePolicy)policy
{
    NSAssert([JSONs isKindOfClass:[NSArray class]], @"JSONs should be a NSArray");
    NSAssert1([self respondsToSelector:@selector(JSONKeyPathsByPropertyKey)],  @"%@ class should impliment +(NSDictionary *)JSONKeyPathsByPropertyKey; method", NSStringFromClass(self));
    NSMutableArray *objs = [NSMutableArray array];
    
    NSDictionary *mapping = [self performSelector:@selector(JSONKeyPathsByPropertyKey)];
    NSSet *primaryKeys = nil;
    if ([self respondsToSelector:@selector(uniquedPropertyKeys)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        primaryKeys = [self performSelector:@selector(uniquedPropertyKeys)];
#pragma clang diagnostic pop
    }
    
    NSManagedObjectContext *context = [self defaultPrivateContext];
    for (NSDictionary *JSON in JSONs) {
        [objs addObject:[self objectWithJSON:JSON
                                 primaryKeys:primaryKeys
                                     mapping:mapping
                     relationshipMergePolicy:policy
                                   inContext:context]];
        
    }
    return objs;
}

+(id)     objectWithJSON:(NSDictionary *)JSON
             primaryKeys:(NSSet *)primaryKeys
                 mapping:(NSDictionary *)mapping
 relationshipMergePolicy:(ARRelationshipMergePolicy)policy
               inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool {
        [context performBlockAndWait:^{
            // find or create the entity object
            if (primaryKeys == nil || primaryKeys.count == 0) {
                entity = [self AR_newInContext:context];
            }else{
                
                //create a compumd predicate
                NSMutableArray *subPredicates = [NSMutableArray array];
                for (NSString *primaryKey in primaryKeys) {
                    NSString *mappingKey = [mapping valueForKey:primaryKey];
                    
                    NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:[self AR_entityName] inManagedObjectContext:context] attributesByName] objectForKey:primaryKey];
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
                NSManagedObjectID *objectID = [[self objectIDStore] objectForKey:compoundPredicate.predicateFormat];
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
                        [[self objectIDStore] setObject:[entity.objectID copy] forKey:compoundPredicate.predicateFormat];
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
                    id value = [self performSelector:selector withObject:JSON[obj]];
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
            
        }];
    }
    return entity;
}

@end
