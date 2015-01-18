//
//  FEMManagedObjectDeserializer+ARAdditions.m
//  Board
//
//  Created by August on 14/12/19.
//
//

#import "FEMManagedObjectDeserializer+ARAdditions.h"
#import "ARCoreDataPersistanceController.h"

@implementation FEMManagedObjectDeserializer (ARAdditions)

#pragma mark - public methods

+(id)parseToObjectWithInfo:(NSDictionary *)info mapping:(FEMManagedObjectMapping *)mapping
{
    return [FEMManagedObjectDeserializer deserializeObjectExternalRepresentation:info usingMapping:mapping context:[self manageObjectContext]];
}

+(NSArray *)parseToObjectsWithInfos:(NSArray *)infos mapping:(FEMManagedObjectMapping *)mapping
{
    return [FEMManagedObjectDeserializer deserializeCollectionExternalRepresentation:infos usingMapping:mapping context:[self manageObjectContext]];
}

#pragma mark - private methods

+(NSManagedObjectContext *)manageObjectContext
{
    return [[ARCoreDataPersistanceController sharePersistanceController] managedObjectContext];
}

@end
