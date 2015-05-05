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

#pragma mark - ARManageObjectMappingProtocol create

+(NSCache *)cacheLocalObjects
{
    static NSCache *localObjects = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localObjects = [[NSCache alloc] init];
    });
    
    return localObjects;
}

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
    NSString *primaryKey = nil;
    if ([self respondsToSelector:@selector(primaryKey)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        primaryKey = [self performSelector:@selector(primaryKey)];
#pragma clang diagnostic pop
    }
    
    NSManagedObjectContext *context = [self defaultPrivateContext];
    for (NSDictionary *JSON in JSONs) {
        [objs addObject:[self objectWithJSON:JSON
                                  primaryKey:primaryKey
                                     mapping:mapping
                     relationshipMergePolicy:policy
                                   inContext:context]];
        
    }
    [[self cacheLocalObjects] removeAllObjects];
    return objs;
}

+(id)     objectWithJSON:(NSDictionary *)JSON
              primaryKey:(NSString *)primaryKey
                 mapping:(NSDictionary *)mapping
 relationshipMergePolicy:(ARRelationshipMergePolicy)policy
               inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool {
        [context performBlockAndWait:^{
            // find or create the entity object
            if (primaryKey == nil) {
                entity = [self AR_newInContext:context];
            }else{
                NSString *mappingKey = [mapping valueForKey:primaryKey];
                
                NSAttributeDescription *attributeDes = [[[NSEntityDescription entityForName:[self AR_entityName] inManagedObjectContext:context] attributesByName] objectForKey:primaryKey];
                id remoteValue = [JSON valueForKeyPath:mappingKey];
                if (attributeDes.attributeType == NSStringAttributeType) {
                    remoteValue = [remoteValue description];
                }else{
                    remoteValue = [NSNumber numberWithLongLong:[remoteValue longLongValue]];
                }
                
                NSString *cacheKey = [NSString stringWithFormat:@"%@.%@=%@",NSStringFromClass(self),primaryKey,remoteValue];
                entity = [[self cacheLocalObjects] objectForKey:cacheKey];
                if (entity == nil) {
                    entity = [self localManageObjectWithPrimaryKey:primaryKey
                                                             value:remoteValue
                                                         inContext:context];
                    
                    if (entity == nil) {
                        entity = [self AR_newInContext:context];
                    }
                    [[self cacheLocalObjects] setObject:entity forKey:cacheKey];
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

+(NSManagedObject *)localManageObjectWithPrimaryKey:(NSString *)primaryKey
                                              value:(id)value
                                          inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",primaryKey,value];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self AR_entityName]];
    fetchRequest.fetchLimit = 1;
    [fetchRequest setPredicate:predicate];
    
    return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
}

@end
