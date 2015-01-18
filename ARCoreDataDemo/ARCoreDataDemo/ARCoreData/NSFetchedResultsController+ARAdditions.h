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
                                            ascending:(BOOL)ascending;

+(instancetype) fetchedResultControllerWithEntityName:(NSString *)entityName
                                                where:(NSString *)filterCondition
                                            batchSize:(NSUInteger)batchSize
                                        sortedKeyPath:(NSString *)sortedKeyPath
                                            ascending:(BOOL)ascending
                                   sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                            cacheName:(NSString *)cacheName;

@end
