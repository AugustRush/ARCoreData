//
//  NSManagedObjectContext+ARAddtions.m
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

#import "NSManagedObjectContext+ARAddtions.h"

@implementation NSManagedObjectContext (ARAddtions)

- (NSArray *)objectsWithObjectIDs:(NSArray *)objectIDs
{
    if (!objectIDs || objectIDs.count == 0) {
        return nil;
    }
    __block NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:objectIDs.count];
    
    [self performBlockAndWait:^{
        for (NSManagedObjectID *objectID in objectIDs) {
            if ([objectID isKindOfClass:[NSNull class]]) {
                continue;
            }
            
            [objects addObject:[self objectWithID:objectID]];
        }
    }];
    
    return objects.copy;
}

@end
