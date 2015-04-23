//
//  NSFetchedResultsController+ARAdditions.h
//  Board
//
//  Created by August on 14/12/16.
//
//

#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (ARAdditions)

+(instancetype) fetchedResultControllerWithEntityName:(NSString *)entityName
                                                where:(NSString *)filterCondition
                                            batchSize:(NSUInteger)batchSize
                                        sortedKeyPath:(NSString *)sortedKeyPath
                                            ascending:(BOOL)ascending
                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

+(instancetype) fetchedResultControllerWithEntityName:(NSString *)entityName
                                                where:(NSString *)filterCondition
                                            batchSize:(NSUInteger)batchSize
                                        sortedKeyPath:(NSString *)sortedKeyPath
                                            ascending:(BOOL)ascending
                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                   sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                            cacheName:(NSString *)cacheName;

@end
