//
//  NSManagedObjectID+ARAddtions.m
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

#import "NSManagedObjectID+ARAddtions.h"
#import "ARCoreDataManager.h"

@implementation NSManagedObjectID (ARAddtions)

- (NSString *)stringRepresentation
{
    return [[self URIRepresentation] absoluteString];
}

@end