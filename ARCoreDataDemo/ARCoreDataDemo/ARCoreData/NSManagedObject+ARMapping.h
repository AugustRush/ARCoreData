//
//  NSManagedObject+ARMapping.h
//  Board
//
//  Created by August on 15/1/26.
//
//

@import CoreData;

@protocol ARManageObjectMappingProtocol <NSObject>

+(NSDictionary *)JSONKeyPathsByPropertyKey;

@optional
+(NSString *)primaryKey;

@end

@interface NSManagedObject (ARMapping)

// Mapping methods
+(id)fillWithJSON:(NSDictionary *)JSON;
+(NSArray *)fillWithJSONs:(NSArray *)JSONs;

@end
