//
//  ARCollectionViewFetchResultController.m
//  Board
//
//  Created by August on 15/4/23.
//
//

#import "ARCollectionViewFetchResultController.h"
#import "NSManagedObject+ARConvenience.h"

#define AR_changeType @"type"
#define AR_changeIndexPath1 @"change_indexPath1"
#define AR_changeIndexPath2 @"change_indexPath2"
#define AR_changeIndex @"_change_index"

@interface ARCollectionViewFetchResultController ()<NSFetchedResultsControllerDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *cellReuseIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;

@property (atomic, strong) NSMutableArray *objectChanges;
@property (atomic, strong) NSMutableArray *sectionChanges;

@end

@implementation ARCollectionViewFetchResultController

-(instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest collectionView:(UICollectionView *)collectionView cellReuseIdentifier:(NSString *)cellReuseIdentifier delegate:(id<ARCollectionViewFetchResultControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        NSManagedObjectContext *manageContex = [[ARCoreDataManager shareManager] mainContext];
        self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manageContex sectionNameKeyPath:nil cacheName:nil];
        self.fetchResultController.delegate = self;
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.cellReuseIdentifier = cellReuseIdentifier;
        self.delegate = delegate;
        
        self.objectChanges = [NSMutableArray array];
        self.sectionChanges = [NSMutableArray array];
        
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
    NSManagedObject *object = [self.fetchResultController objectAtIndexPath:indexPath];
    return [object AR_objectInPrivate];
}

-(void)setPause:(BOOL)pause
{
    if (pause != _pause) {
        _pause = pause;
        if (_pause) {
            self.collectionView.dataSource = nil;
        }else{
            self.collectionView.dataSource = self;
            NSError *error;
            if (![self.fetchResultController performFetch:&error]) {
                NSLog(@"%s error is %@",__PRETTY_FUNCTION__,error);
            }
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if ([self.delegate respondsToSelector:@selector(collectionFetchResultControllerWillChangedContent:)]) {
        [self.delegate collectionFetchResultControllerWillChangedContent:self];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^{
        
        [self.sectionChanges enumerateObjectsUsingBlock:^(NSDictionary *changeInfo, NSUInteger idx, BOOL *stop) {
            NSFetchedResultsChangeType type = [[changeInfo objectForKey:AR_changeType] integerValue];
            NSUInteger index = [[changeInfo objectForKey:AR_changeIndex] integerValue];
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
                    break;
                case NSFetchedResultsChangeDelete:
                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:index]];
                    break;
                case NSFetchedResultsChangeMove:

                    break;
                case NSFetchedResultsChangeUpdate:
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self.objectChanges enumerateObjectsUsingBlock:^(NSDictionary *changeInfo, NSUInteger idx, BOOL *stop) {
            NSFetchedResultsChangeType type = [[changeInfo objectForKey:AR_changeType] integerValue];
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    [self.collectionView insertItemsAtIndexPaths:@[changeInfo[AR_changeIndexPath1]]];
                    break;
                case NSFetchedResultsChangeMove:
                    [self.collectionView moveItemAtIndexPath:changeInfo[AR_changeIndexPath1] toIndexPath:changeInfo[AR_changeIndexPath2]];
                    break;
                case NSFetchedResultsChangeUpdate:
                    [self.collectionView reloadItemsAtIndexPaths:@[changeInfo[AR_changeIndexPath1]]];
                    break;
                case NSFetchedResultsChangeDelete:
                    [self.collectionView deleteItemsAtIndexPaths:@[changeInfo[AR_changeIndexPath1]]];
                    break;
                    
                default:
                    break;
            }
        }];
    } completion:^(BOOL finished) {
        [self.objectChanges removeAllObjects];
        [self.sectionChanges removeAllObjects];
        
        if ([self.delegate respondsToSelector:@selector(collectionFetchResultControllerDidChangedContent:)]) {
            [self.delegate collectionFetchResultControllerDidChangedContent:self];
        }
    }];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.objectChanges addObject:@{AR_changeType:@(type),
                                            AR_changeIndexPath1:newIndexPath}];
            break;
        case NSFetchedResultsChangeMove:
            [self.objectChanges addObject:@{AR_changeType:@(type),
                                            AR_changeIndexPath1:indexPath,
                                            AR_changeIndexPath2:newIndexPath}];
            break;
        case NSFetchedResultsChangeUpdate:
            if ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                if ([self.delegate respondsToSelector:@selector(collectionFetchResultController:updateCell:withObject:)]) {
                    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                    [self.delegate collectionFetchResultController:self updateCell:cell withObject:anObject];
                }else{
                    [self.objectChanges addObject:@{AR_changeType:@(type),
                                                    AR_changeIndexPath1:indexPath}];
                }
            }
            break;
        case NSFetchedResultsChangeDelete:
            [self.objectChanges addObject:@{AR_changeType:@(type),
                                            AR_changeIndexPath1:indexPath}];
            break;
            
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.sectionChanges addObject:@{AR_changeType:@(type),
                                            AR_changeIndex:@(sectionIndex)}];
            break;
        case NSFetchedResultsChangeMove:
            //not impliment
            break;
        case NSFetchedResultsChangeUpdate:
            [self.sectionChanges addObject:@{AR_changeType:@(type),
                                             AR_changeIndex:@(sectionIndex)}];
            break;
        case NSFetchedResultsChangeDelete:
            [self.sectionChanges addObject:@{AR_changeType:@(type),
                                             AR_changeIndex:@(sectionIndex)}];
            break;
            
            
        default:
            break;
    }
    
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchResultController.sections.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchResultController sections][section];
    return [sectionInfo numberOfObjects];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    id object = [self.fetchResultController objectAtIndexPath:indexPath];
    [self.delegate collectionFetchResultController:self configureCell:cell withObject:[object AR_objectInPrivate]];
    return cell;
}


@end
