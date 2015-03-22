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

@implementation NSManagedObject (ARMapping)

#pragma mark - transfrom methods

#warning 优化效率，错误修正
+(id)fillWithJSON:(NSDictionary *)JSON
{
    NSAssert([self respondsToSelector:@selector(JSONKeyPathsByPropertyKey)], @"NSManageObject should impliment +(NSDictionary *)JSONKeyPathsByPropertyKey; method");
    
    NSDictionary *mapping = [self performSelector:@selector(JSONKeyPathsByPropertyKey)];
  
    
    NSManagedObject *entity = nil;
    if ([self respondsToSelector:@selector(uniquedPropertyKeys)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSSet *set = [self performSelector:@selector(uniquedPropertyKeys)];
#pragma clang diagnostic pop
        if (set == nil) {
            entity = [self AR_new];
        }else{
            NSMutableArray *predicates = [NSMutableArray array];
            [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                NSString *mappingKey = mapping[obj];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",obj,JSON[mappingKey]];
                [predicates addObject:predicate];
            }];
            NSCompoundPredicate *uniquedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            entity = [self AR_anyoneWithPredicate:uniquedPredicate];
            if (entity == nil) {
                entity = [self AR_new];
            }
        }
    }else{
        entity = [self AR_new];
    }
    
    
    NSArray *attributes = [entity allAttributeNames];
    NSArray *relationships = [entity allRelationshipNames];
    [mapping enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        
        if ([attributes containsObject:key]) {
            NSAttributeDescription *attributeDes = [entity attributeDescriptionForAttribute:key];
        
            NSString *methodName = [NSString stringWithFormat:@"%@Transformer:",key];
            SEL selector = NSSelectorFromString(methodName);
            if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id value = [self performSelector:selector withObject:JSON[obj]];
#pragma clang diagnostic pop
                [entity setValue:value forKey:key];
            }else{
                id value = nil;
                if ([JSON isKindOfClass:[NSDictionary class]]) {
                    value = JSON[obj];
                }
                if (value != nil) {
                    switch (attributeDes.attributeType) {
                        case NSInteger16AttributeType:
                        case NSInteger32AttributeType:
                        {
                            [entity setValue:@([value intValue]) forKey:key];
                        }
                            break;
                        case NSInteger64AttributeType:
                        {
                            [entity setValue:@([value longLongValue]) forKey:key];
                        }
                            break;
                        case NSDoubleAttributeType:
                        {
                            [entity setValue:@([value doubleValue]) forKey:key];
                        }
                            break;
                        case NSFloatAttributeType:
                        {
                            [entity setValue:@([value floatValue]) forKey:key];
                        }
                            break;
                        case NSBooleanAttributeType:
                        {
                            [entity setValue:@([value boolValue]) forKey:key];
                        }
                            break;
                        case NSDateAttributeType:
                        case NSObjectIDAttributeType:
                        case NSBinaryDataAttributeType:
                        case NSStringAttributeType:
                        {
                            [entity setValue:value forKey:key];
                        }
                            break;
                        case NSTransformableAttributeType:
                        {
                        
                        }
                            break;
                        case NSUndefinedAttributeType:
                        {
                        
                        }
                            break;
                        default:
                            break;
                    }
                }
            }

        }else if ([relationships containsObject:key]){
            NSRelationshipDescription *relationshipDes = [entity relationshipDescriptionForRelationship:key];
            NSString *desClassName = relationshipDes.destinationEntity.managedObjectClassName;
            id subJSON = JSON[obj];
            if (relationshipDes.isToMany) {
                NSArray *detinationObjs = [NSClassFromString(desClassName) fillWithJSONs:subJSON];
                NSMutableSet *existObjs = [NSMutableSet setWithSet:[entity valueForKey:key]];
                [existObjs addObjectsFromArray:detinationObjs];
                [entity setValue:existObjs forKey:key];
            }else{
                if (subJSON != nil) {
                    id destinationObj = [NSClassFromString(desClassName) fillWithJSON:subJSON];
                    [entity setValue:destinationObj forKey:key];
                }
            }
        }
    }];
    return entity;
}

+(NSArray *)fillWithJSONs:(NSArray *)JSONs
{
    NSMutableArray *objs = [NSMutableArray array];
    [JSONs enumerateObjectsUsingBlock:^(NSDictionary *JSON, NSUInteger idx, BOOL *stop) {
        [objs addObject:[self fillWithJSON:JSON]];
    }];
    return objs;
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

@end
