//
//  NSManagedObjectContext+ARAddtions.m
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

#import "NSManagedObjectContext+ARAddtions.h"
#import "ARCoreDataManager.h"

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
    
    return objects;
}

-(NSArray *)objectsWithURIRepresentations:(NSArray *)URIRepresentations
{
    if (!URIRepresentations || URIRepresentations.count == 0) {
        return nil;
    }
    
    __block NSPersistentStoreCoordinator *coordinator = [[ARCoreDataManager shareManager] persistentStoreCoordinator];
    __block NSMutableArray *objects = [NSMutableArray arrayWithCapacity:URIRepresentations.count];
    [self performBlockAndWait:^{
        for (NSURL *URL in URIRepresentations) {
            NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:URL];
            if (objectID == nil) {
                continue;
            }
            [objects addObject:[self objectWithID:objectID]];
        }
    }];
    return objects;
}


@end
