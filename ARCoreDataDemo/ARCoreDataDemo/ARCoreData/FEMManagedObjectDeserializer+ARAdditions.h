//
//  FEMManagedObjectDeserializer+ARAdditions.h
//  Board
//
//  Created by August on 14/12/19.
//
//

#import "FEMManagedObjectDeserializer.h"

@interface FEMManagedObjectDeserializer (ARAdditions)

+(id)parseToObjectWithInfo:(NSDictionary *)info mapping:(FEMManagedObjectMapping *)mapping;
+(NSArray *)parseToObjectsWithInfos:(NSArray *)infos mapping:(FEMManagedObjectMapping *)mapping;

@end
