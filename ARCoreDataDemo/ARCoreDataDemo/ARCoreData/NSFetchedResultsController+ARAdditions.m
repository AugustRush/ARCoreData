//
//  NSFetchedResultsController+ARAdditions.m
//  Board
//
//  Created by August on 14/12/16.
//
//

#import "NSFetchedResultsController+ARAdditions.h"
#import "ARCoreDataManager.h"

@implementation NSFetchedResultsController (ARAdditions)

+(instancetype)fetchedResultControllerWithEntityName:(NSString *)entityName
                                               where:(NSString *)filterCondition
                                           batchSize:(NSUInteger)batchSize
                                       sortedKeyPath:(NSString *)sortedKeyPath
                                           ascending:(BOOL)ascending
                                            delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    return [self fetchedResultControllerWithEntityName:entityName
                                                 where:filterCondition
                                             batchSize:batchSize
                                         sortedKeyPath:sortedKeyPath
                                             ascending:ascending
                                              delegate:delegate
                                    sectionNameKeyPath:nil
                                             cacheName:nil];
}

+(instancetype)fetchedResultControllerWithEntityName:(NSString *)entityName
                                               where:(NSString *)filterCondition
                                           batchSize:(NSUInteger)batchSize
                                       sortedKeyPath:(NSString *)sortedKeyPath
                                           ascending:(BOOL)ascending
                                            delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                  sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                           cacheName:(NSString *)cacheName
{
    ARCoreDataManager *persistanceController = [ARCoreDataManager shareManager];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.fetchBatchSize = batchSize;
    if (filterCondition != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:filterCondition];
        fetchRequest.predicate = predicate;
    }
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:sortedKeyPath ascending:ascending];
    fetchRequest.sortDescriptors = @[sortDes];
    NSFetchedResultsController *fetchResultController = [[NSFetchedResultsController alloc]
                                                         initWithFetchRequest:fetchRequest
                                                         managedObjectContext:[persistanceController mainContext]
                                                         sectionNameKeyPath:sectionNameKeyPath
                                                         cacheName:cacheName];
    fetchResultController.delegate = delegate;
    
    return fetchResultController;
}

@end
