//
//  NSManagedObjectContext+ARAddtions.h
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

@import CoreData;

@interface NSManagedObjectContext (ARAddtions)

- (NSArray *)objectsWithObjectIDs:(NSArray *)objectIDs;
- (NSArray *)objectsWithURIRepresentations:(NSArray *)URIRepresentations;

@end
