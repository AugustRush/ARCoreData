//
//  NSManagedObject+ARRequest.m
//  Board
//
//  Created by August on 15/3/14.
//
//

#import "NSManagedObject+ARRequest.h"

@implementation NSManagedObject (ARRequest)

+(NSString *)AR_entityName
{
    return NSStringFromClass(self);
}

+(NSFetchRequest *)AR_allRequest
{
    return [self AR_requestWithFetchLimit:0
                                batchSize:0];
}

+(NSFetchRequest *)AR_anyoneRequest
{
    return [self AR_requestWithFetchLimit:1
                                batchSize:1];
}

+(NSFetchRequest *)AR_requestWithFetchLimit:(NSUInteger)limit
                                  batchSize:(NSUInteger)batchSize
{
    return [self AR_requestWithFetchLimit:limit batchSize:batchSize fetchOffset:0];
}

+(NSFetchRequest *)AR_requestWithFetchLimit:(NSUInteger)limit
                                  batchSize:(NSUInteger)batchSize
                                fetchOffset:(NSUInteger)fetchOffset
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self AR_entityName]];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchBatchSize = batchSize;
    fetchRequest.fetchOffset = fetchOffset;
    return fetchRequest;
}

@end
