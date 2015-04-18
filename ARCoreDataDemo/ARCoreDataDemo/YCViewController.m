//
//  YCViewController.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "YCViewController.h"
#import "ARCoreData/ARCoreData.h"
#import "Person.h"
#import "Dog.h"

@interface YCViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

- (IBAction)addEntityObj:(id)sender;
@end

@implementation YCViewController

#pragma mark - lifeCycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - fetch controller

-(NSFetchedResultsController *)fetchController
{
    if (_fetchController != nil) {
        return _fetchController;
    }
    _fetchController = [NSFetchedResultsController fetchedResultControllerWithEntityName:[Dog AR_entityName]
                                                                                   where:nil
                                                                               batchSize:10
                                                                           sortedKeyPath:@"name" ascending:NO
                                                                                delegate:self];
    return _fetchController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dog *dog = [self.fetchController objectAtIndexPath:indexPath];
    [dog AR_delete];
    
    [Person saveWithHandler:^(NSError *error) {
        NSLog(@"delete dog error is %@",error);
    }];
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchController.sections[section] numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
    }
    
    Dog *dog = [self.fetchController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = dog.name;
    cell.detailTextLabel.text = [dog.owners.anyObject name];
    
    return cell;
}

#pragma mark - manage memory methods

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)addEntityObj:(id)sender {
    for (int i = 1; i < 3; i++) {
        NSString *name = [NSString stringWithFormat:@"%u",arc4random()];
        NSString *guid = [NSString stringWithFormat:@"%u",arc4random()%4];
        Person *person = [Person fillWithJSON:@{@"n":name,
                                                @"g":@"3",
                                                @"s":@YES,
                                                @"ds":@[@{@"n":name},
                                                        @{@"n":name}]}];
    }
    
    [Person saveWithHandler:^(NSError *error) {
        NSLog(@"all person is %@",[Person AR_all]);
    }];
    
}
@end
