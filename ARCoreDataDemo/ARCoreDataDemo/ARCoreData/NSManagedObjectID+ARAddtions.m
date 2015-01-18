//
//  NSManagedObjectID+ARAddtions.m
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

#import "NSManagedObjectID+ARAddtions.h"
#import "ARCoreDataPersistanceController.h"

@implementation NSManagedObjectID (ARAddtions)

- (NSString *)stringRepresentation
{
    return [[self URIRepresentation] absoluteString];
}

@end
