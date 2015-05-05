//
//  ARFetchResultController.m
//  Board
//
//  Created by August on 15/4/23.
//
//

#import "ARTableViewFetchResultController.h"

@interface ARTableViewFetchResultController ()<UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *cellReuseIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;

@end

@implementation ARTableViewFetchResultController

-(instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest tableView:(UITableView *)tableView cellReuseIdentifier:(NSString *)cellReuseIdentifier delegate:(id<ARTableViewFetchResultControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        NSManagedObjectContext *manageContex = [[ARCoreDataManager shareManager] mainContext];
        self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manageContex sectionNameKeyPath:nil cacheName:nil];
        self.fetchResultController.delegate = self;
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.cellReuseIdentifier = cellReuseIdentifier;
        self.delegate = delegate;
        
        NSError *error;
        if (![self.fetchResultController performFetch:&error]) {
            NSLog(@"%s error is %@",__PRETTY_FUNCTION__,error);
        }
    }
    return self;
}

#pragma mark - private methods

-(NSArray *)sections
{
    return self.fetchResultController.sections;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchResultController objectAtIndexPath:indexPath];
}

#pragma mark - NSFetchedResultsControllerDelegate methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    if ([self.delegate respondsToSelector:@selector(tableFetchResultControllerWillChangedContent:)]) {
        [self.delegate tableFetchResultControllerWillChangedContent:self];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    if ([self.delegate respondsToSelector:@selector(tableFetchResultControllerDidChangedContent:)]) {
        [self.delegate tableFetchResultControllerDidChangedContent:self];
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if ([self.delegate respondsToSelector:@selector(tableFetchResultController:updateCell:withObject:)]) {
                    [self.delegate tableFetchResultController:self updateCell:cell withObject:anObject];
                }else{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

            
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:

            break;
        case NSFetchedResultsChangeMove:

            break;
        case NSFetchedResultsChangeUpdate:

            break;
        case NSFetchedResultsChangeDelete:

            break;
            
            
        default:
            break;
    }

}

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchResultController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchResultController sections][section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    id object = [self.fetchResultController objectAtIndexPath:indexPath];
    [self.delegate tableFetchResultController:self configureCell:cell withObject:object];
    return cell;
}

@end
