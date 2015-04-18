//
//  NSManagedObject+ARMapping.m
//  Board
//
//  Created by August on 15/1/26.
//
//

#import "NSManagedObject+ARMapping.h"
#import "NSManagedObject+ARFetch.h"
#import "NSManagedObject+ARCreate.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "NSManagedObject+ARRequest.h"

@implementation NSManagedObject (ARMapping)

+(NSMutableDictionary *)cacheLocalObjects
{
    static NSMutableDictionary *localObjects = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localObjects = [NSMutableDictionary dictionary];
    });
    
    return localObjects;
}

#pragma mark - transfrom methods

+(id)fillWithJSON:(NSDictionary *)JSON
{
    if (JSON != nil) {
        return [[self fillWithJSONs:@[JSON]] lastObject];
    }
    return nil;
}

+(NSArray *)fillWithJSONs:(NSArray *)JSONs
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
                                   inContext:context]];
    
    }
    [[self cacheLocalObjects] removeAllObjects];
    return objs;
}

+(id)objectWithJSON:(NSDictionary *)JSON
         primaryKey:(NSString *)primaryKey
            mapping:(NSDictionary *)mapping
          inContext:(NSManagedObjectContext *)context
{
    __block NSManagedObject *entity = nil;
    @autoreleasepool {
    [context performBlockAndWait:^{
            // find or create the entity object
            if (primaryKey == nil) {
                entity = [self AR_newInContext:context];
            }else{
                NSString *mappingKey = mapping[primaryKey];
                id remoteValue = JSON[mappingKey];
                
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
                        [entity mergeAttributeForKey:key withValue:[JSON valueForKey:obj]];
                        
                        
                    }else if ([relationships containsObject:key]){
                        [entity mergeRelationshipForKey:key withObject:[JSON valueForKey:obj]];
                    }                
                
                }

        }];
        
    }];
    }
    return entity;
}

-(void)mergeAttributeForKey:(NSString *)attributeName withValue:(id)value
{
    NSAttributeDescription *attributeDes = [self attributeDescriptionForAttribute:attributeName];
    
    if (value != nil && value != [NSNull null]) {
        switch (attributeDes.attributeType) {
            case NSDecimalAttributeType:
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSDoubleAttributeType:
            case NSFloatAttributeType:
                [self setValue:numberFromString([value description]) forKey:attributeName];
                break;
            case NSBooleanAttributeType:
                [self setValue:[NSNumber numberWithBool:[value boolValue]] forKey:attributeName];
                break;
            case NSDateAttributeType:
                [self setValue:dateFromString(value) forKey:attributeName];
            case NSObjectIDAttributeType:
            case NSBinaryDataAttributeType:
            case NSStringAttributeType:
                [self setValue:[NSString stringWithFormat:@"%@",value] forKey:attributeName];
                break;
            case NSTransformableAttributeType:
            case NSUndefinedAttributeType:
                break;
            default:
                break;
        }
    }

}

-(void)mergeRelationshipForKey:(NSString *)relationshipName withObject:(id)object
{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return;
    }
    NSRelationshipDescription *relationshipDes = [self relationshipDescriptionForRelationship:relationshipName];
    NSString *desClassName = relationshipDes.destinationEntity.managedObjectClassName;
    if (relationshipDes.isToMany) {
        NSArray *destinationObjs = [NSClassFromString(desClassName) fillWithJSONs:object];
        NSMutableSet *localSet = [self mutableSetValueForKey:relationshipName];
        if (destinationObjs != nil && destinationObjs.count > 0) {
            [localSet addObjectsFromArray:destinationObjs];
            [self setValue:localSet forKey:relationshipName];
        }
    }else{
        id destinationObjs = [NSClassFromString(desClassName) fillWithJSON:object];
        [self setValue:destinationObjs forKey:relationshipName];
    }

}

+(NSManagedObject *)localManageObjectWithPrimaryKey:(NSString *)primaryKey
                                              value:(id)value
                                          inContext:(NSManagedObjectContext *)context
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",primaryKey,[value description]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self AR_entityName]];
    fetchRequest.fetchLimit = 1;
    [fetchRequest setPredicate:predicate];
    
    return [[context executeFetchRequest:fetchRequest error:nil] lastObject];
}

#pragma mark - private methods

-(NSArray *)allAttributeNames
{
    return self.entity.attributesByName.allKeys;
}

-(NSArray *)allRelationshipNames
{
    return self.entity.relationshipsByName.allKeys;
}

-(NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName
{
    return [self.entity.attributesByName objectForKey:attributeName];
}

-(NSRelationshipDescription *)relationshipDescriptionForRelationship:(NSString *)relationshipName
{
    return [self.entity.relationshipsByName objectForKey:relationshipName];
}

#pragma mark - transform methods

NSDate * dateFromString(NSString *value)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    
    NSDate *parsedDate = [formatter dateFromString:value];
    
    return parsedDate;
}

NSNumber * numberFromString(NSString *value) {
    return [NSNumber numberWithDouble:[value doubleValue]];
}

@end
