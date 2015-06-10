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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY owners.guid = %@",@"3"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    [fetchRequest setSortDescriptors:@[sorted]];
    
    self.fetchController = [[ARTableViewFetchResultController alloc] initWithFetchRequest:fetchRequest tableView:self.tableView cellReuseIdentifier: @"cell" delegate:self];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - ARTableViewFetchResultControllerDelegate methods

-(void)tableFetchResultController:(ARTableViewFetchResultController *)controller configureCell:(UITableViewCell *)cell withObject:(id)object
{
    Dog *dog = (Dog *)object;
    cell.textLabel.text = [NSString stringWithFormat:@"%lld %@",dog.guid,dog.name];
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dog *dog = [self.fetchController objectAtIndexPath:indexPath];
    [dog AR_delete];
    
    [Person AR_saveCompletion:^(BOOL success, NSError *error) {
        NSLog(@"all dog count is %ld",(unsigned long)[Dog AR_count]);
        
        NSLog(@"all person count is %ld",(unsigned long)[Person AR_count]);
    }];
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
    
//    NSLog(@"start mapping");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *JSONs = [NSMutableArray array];
        for (int i = 1; i < 30; i++) {
            NSString *name = [NSString stringWithFormat:@"%u",arc4random()%4];
            NSString *guid = [NSString stringWithFormat:@"%u",arc4random()%20];
            [JSONs addObject:@{@"n":name,
                              @"g":@"3",
                              @"s":@YES,
                              @"ds":@[@{@"n":guid,
                                        @"g":@{@"uid":@6,
                                               @"extra":@34}},
                                      @{@"n":name,
                                        @"g":@{@"uid":@"6",
                                               @"extra":@34}}]}];
        }
        
        //因为Person的primarykey是“guid”，而在mapping中对应的为“g”，所以只要g为相同的值，那么就只会创建一个Person实例，可以加上for循环，或者多次点击添加进行测试
        
        [Person AR_syncWithJSONs:JSONs completion:^(NSArray *objects) {

        }];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *JSONs = [NSMutableArray array];
        for (int i = 1; i < 30; i++) {
            NSString *name = [NSString stringWithFormat:@"%u",arc4random()%4];
            NSString *guid = [NSString stringWithFormat:@"%u",arc4random()%20];
            [JSONs addObject:@{@"n":name,
                               @"g":@"3",
                               @"s":@YES,
                               @"ds":@[@{@"n":guid,
                                         @"g":@{@"uid":@6,
                                                @"extra":@34}},
                                       @{@"n":name,
                                         @"g":@{@"uid":@"6",
                                                @"extra":@34}}]}];
        }
        
        //因为Person的primarykey是“guid”，而在mapping中对应的为“g”，所以只要g为相同的值，那么就只会创建一个Person实例，可以加上for循环，或者多次点击添加进行测试
        
        [Person AR_syncWithJSONs:JSONs completion:^(NSArray *objects) {
            NSLog(@"all person count is %ld",[Person AR_count]);
            NSLog(@"all dogs count is %ld",[Dog AR_count]);
        }];
    });

    
//    NSLog(@"stop mapping");
    
}

@end
