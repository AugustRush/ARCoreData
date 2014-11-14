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
#import "EntityO.h"

@interface YCViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSManagedObjectContext *context;

- (IBAction)addEntityObj:(id)sender;
@end

@implementation YCViewController

#pragma mark - lifeCycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray array];
    
    self.context = [ARCoreDataPersistanceController sharePersistanceController].managedObjectContext;
    [self refreshData];
}

-(void)refreshData{

    [self.dataArr removeAllObjects];
//    [[ARCoreDataPersistanceController sharePersistanceController] fetchAllObjectsWithEntityName:@"Person" finishedBlock:^(NSArray *objs, NSError *error) {
//        NSLog(@"array count is %ld error is %@",objs.count,error);
//        [self.dataArr addObjectsFromArray:objs];
//        [self.tableView reloadData];
//    }];
    
    NSFetchRequest *fetReq = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
//    [fetReq setFetchLimit:5];
    [[ARCoreDataPersistanceController sharePersistanceController] fetchObjectsWithFetchRequest:fetReq finishedBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"array count is %ld error is %@",objects.count,error);
        [self.dataArr addObjectsFromArray:objects];
        [self.tableView reloadData];

    }];
    
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select");

    [[ARCoreDataPersistanceController sharePersistanceController] deleteObjects:[NSSet setWithArray:self.dataArr] finishedBlock:^(NSError *error) {
        [self refreshData];
    }];
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
    }
    
    Person *person = self.dataArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",person.name];
    cell.detailTextLabel.text = person.sex;
    
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
    
    
}
@end
