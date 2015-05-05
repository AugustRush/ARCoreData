//
//  ARFetchResultController.h
//  Board
//
//  Created by August on 15/4/23.
//
//

#import <Foundation/Foundation.h>
#import "ARCoreDataManager.h"

@class ARTableViewFetchResultController;
@protocol ARTableViewFetchResultControllerDelegate <NSObject>

@required
-(void)tableFetchResultController:(ARTableViewFetchResultController *)controller configureCell:(id)cell withObject:(id)object;

@optional
-(void)tableFetchResultController:(ARTableViewFetchResultController *)controller updateCell:(id)cell withObject:(id)object;

-(void)tableFetchResultControllerDidChangedContent:(ARTableViewFetchResultController *)controller;
-(void)tableFetchResultControllerWillChangedContent:(ARTableViewFetchResultController *)controller;

@end


@interface ARTableViewFetchResultController : NSObject

-(instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                          tableView:(UITableView *)tableView
                cellReuseIdentifier:(NSString *)cellReuseIdentifier
                           delegate:(id<ARTableViewFetchResultControllerDelegate>)delegate;

@property (nonatomic, assign) id<ARTableViewFetchResultControllerDelegate> delegate;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchResultController;

@property (nonatomic, readonly) NSArray *sections;

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
