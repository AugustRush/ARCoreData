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

// Mapping methods
//+(id)fillWithJSON:(NSDictionary *)JSON;
//+(NSArray *)fillWithJSONs:(NSArray *)JSONs;

-(void)mergeAttributeForKey:(NSString *)attributeName withValue:(id)value;
-(void)mergeRelationshipForKey:(NSString *)relationshipName withValue:(id)value;

@end
