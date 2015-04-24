//
//  NSManagedObject+ARMapping.h
//  Board
//
//  Created by August on 15/1/26.
//
//

@import CoreData;
#import "ARManageObjectMappingProtocol.h"

@interface NSManagedObject (ARMapping)

-(void)mergeAttributeForKey:(NSString *)attributeName withValue:(id)value;
-(void)mergeRelationshipForKey:(NSString *)relationshipName withValue:(id)value;

-(NSArray *)allAttributeNames;
-(NSArray *)allRelationshipNames;
-(NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName;
-(NSRelationshipDescription *)relationshipDescriptionForRelationship:(NSString *)relationshipName;

@end
