//
//  YCViewController.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "YCViewController.h"
#import "Person.h"
#import "Dog.h"

@interface YCViewController ()<UITableViewDelegate,ARTableViewFetchResultControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) ARTableViewFetchResultController *fetchController;

- (IBAction)addEntityObj:(id)sender;
@end

@implementation YCViewController

#pragma mark - lifeCycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSFetchRequest *fetchRequest = [Dog AR_allRequest];
    
    NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:@"guid" ascending:NO];
    [fetchRequest setSortDescriptors:@[sorted]];
    
    self.fetchController = [[ARTableViewFetchResultController alloc] initWithFetchRequest:fetchRequest tableView:self.tableView cellReuseIdentifier: @"cell" delegate:self];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - ARTableViewFetchResultControllerDelegate methods

- (void)tableFetchResultController:(ARTableViewFetchResultController *)controller configureCell:(UITableViewCell *)cell withObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    Dog *dog = (Dog *)object;
    cell.textLabel.text = [NSString stringWithFormat:@"%lld %@",dog.guid,dog.name];
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dog *dog = [self.fetchController objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = dog.objectID;
    
    [Person AR_saveAndWait:^(NSManagedObjectContext *currentContext) {
        Dog *deleteDog = (Dog *)[currentContext existingObjectWithID:objectID error:nil];
        [currentContext deleteObject:deleteDog];
    }];
    
    NSLog(@"all dog count is %ld",(unsigned long)[Dog AR_count]);
    NSLog(@"all person count is %ld",(unsigned long)[Person AR_count]);
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [Person AR_save:^(NSManagedObjectContext *currentContext) {
            NSLog(@"start");
            for (int i = 1; i < 3000; i++) {
                NSString *name = [NSString stringWithFormat:@"%u",arc4random()%4];
                NSString *guid = [NSString stringWithFormat:@"%d",i];
                [Person AR_newOrUpdateWithJSON:@{@"n":name,
                                                 @"g":@"3",
                                                 @"s":@YES,
                                                 @"ds":@[@{@"n":guid,
                                                           @"g":@{@"uid":guid,
                                                                  @"extra":@34}},
                                                         @{@"n":name,
                                                           @"g":@{@"uid":guid,
                                                                  @"extra":@34}}]} inContext:currentContext];
            }
            //因为Person的primarykey是“guid”，而在mapping中对应的为“g”，所以只要g为相同的值，那么就只会创建一个Person实例，可以加上for循环，或者多次点击添加进行测试
            NSLog(@"stop");

        } completion:^(NSError *error) {
            NSLog(@"all person count is %lu",(unsigned long)[Person AR_count]);
            NSLog(@"all dogs count is %lu",(unsigned long)[Dog AR_count]);
        }];
    });

    
//    NSLog(@"stop mapping");
    
}

@end
