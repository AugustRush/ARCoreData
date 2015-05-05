//
//  NSManagedObjectID+ARAddtions.h
//  Mindssage
//
//  Created by August on 14/11/20.
//
//

@import CoreData;

@interface NSManagedObjectID (ARAddtions)

- (NSString *)stringRepresentation;

+ (instancetype)objectIDWithURIRepresentation:(NSString *)URIRepresentation;

@end
