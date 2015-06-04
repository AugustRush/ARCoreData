//
//  NSManagedObject+ARMapping.m
//  Board
//
//  Created by August on 15/1/26.
//
//

#import "NSManagedObject+ARMapping.h"
#import "NSManagedObject+ARConvenience.h"
#import "NSManagedObject+ARCreate.h"
#import "NSManagedObject+ARManageObjectContext.h"
#import "NSManagedObject+ARRequest.h"
#import "NSManagedObject+ARCreate.h"
#import "ARCoreDataManager.h"

@implementation NSManagedObject (ARMapping)

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

-(void)mergeRelationshipForKey:(NSString *)relationshipName withValue:(id)value mergePolicy:(ARRelationshipMergePolicy)policy
{
    if (value == nil || [value isEqual:[NSNull null]]) {
        return;
    }
    NSRelationshipDescription *relationshipDes = [self relationshipDescriptionForRelationship:relationshipName];
    NSString *desClassName = relationshipDes.destinationEntity.managedObjectClassName;
    if (relationshipDes.isToMany) {
        NSArray *destinationObjs = [NSClassFromString(desClassName) AR_newOrUpdateWithJSONs:value];
        if (destinationObjs != nil && destinationObjs.count > 0) {
            if (policy == ARRelationshipMergePolicyAdd) {
                if(relationshipDes.isOrdered) {
                    NSMutableOrderedSet *localOrderedSet = [self mutableOrderedSetValueForKey:relationshipName];
                    [localOrderedSet addObjectsFromArray:destinationObjs];
                    [self setValue:localOrderedSet forKey:relationshipName];
                }
                else {
                    NSMutableSet *localSet = [self mutableSetValueForKey:relationshipName];
                    [localSet addObjectsFromArray:destinationObjs];
                    [self setValue:localSet forKey:relationshipName];
                }
            }else{
                if (relationshipDes.isOrdered) {
                    NSMutableOrderedSet *localOrderedSet = [self mutableOrderedSetValueForKey:relationshipName];
                    [localOrderedSet removeAllObjects];
                    [localOrderedSet addObjectsFromArray:destinationObjs];
                    [self setValue:localOrderedSet forKey:relationshipName];
                }else{
                    [self setValue:[NSSet setWithArray:destinationObjs] forKey:relationshipName];
                }
            }
        }
    }else{
        id destinationObjs = [NSClassFromString(desClassName) AR_newOrUpdateWithJSON:value];
        [self setValue:destinationObjs forKey:relationshipName];
    }

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
