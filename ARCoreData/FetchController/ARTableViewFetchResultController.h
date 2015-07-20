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
-(void)tableFetchResultController:(ARTableViewFetchResultController *)controller configureCell:(id)cell withObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@optional
-(void)tableFetchResultController:(ARTableViewFetchResultController *)controller updateCell:(id)cell withObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

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
@property (nonatomic, assign) BOOL pause;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, assign) BOOL reloadWhenDataChanged;//will reload data when data changed without animation

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
