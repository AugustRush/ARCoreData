//
//  ARCollectionViewFetchResultController.h
//  Board
//
//  Created by August on 15/4/23.
//
//

#import <Foundation/Foundation.h>
#import "ARCoreDataManager.h"

@class ARCollectionViewFetchResultController;
@protocol ARCollectionViewFetchResultControllerDelegate <NSObject>

@required
-(void)collectionFetchResultController:(ARCollectionViewFetchResultController *)controller configureCell:(id)cell withObject:(id)object;

@optional
-(void)collectionFetchResultController:(ARCollectionViewFetchResultController *)controller updateCell:(id)cell withObject:(id)object;

-(void)collectionFetchResultControllerDidChangedContent:(ARCollectionViewFetchResultController *)controller;
-(void)collectionFetchResultControllerWillChangedContent:(ARCollectionViewFetchResultController *)controller;


@end

@interface ARCollectionViewFetchResultController : NSObject

-(instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                     collectionView:(UICollectionView *)collectionView
                cellReuseIdentifier:(NSString *)cellReuseIdentifier
                           delegate:(id<ARCollectionViewFetchResultControllerDelegate>)delegate;

@property (nonatomic, assign) id<ARCollectionViewFetchResultControllerDelegate> delegate;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchResultController;

@property (nonatomic, readonly) NSArray *sections;

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;


@end
