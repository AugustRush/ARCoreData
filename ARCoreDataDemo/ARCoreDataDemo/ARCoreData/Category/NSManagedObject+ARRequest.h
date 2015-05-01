//
//  NSManagedObject+ARRequest.h
//  Board
//
//  Created by August on 15/3/14.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ARRequest)

+(NSString *)AR_entityName;

+(NSFetchRequest *)AR_allRequest;

+(NSFetchRequest *)AR_anyoneRequest;

+(NSFetchRequest *)AR_requestWithFetchLimit:(NSUInteger)limit
                                  batchSize:(NSUInteger)batchSize;

+(NSFetchRequest *)AR_requestWithFetchLimit:(NSUInteger)limit
                                  batchSize:(NSUInteger)batchSize
                                fetchOffset:(NSUInteger)fetchOffset;

@end
