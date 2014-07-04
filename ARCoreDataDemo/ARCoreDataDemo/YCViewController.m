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
    [[ARCoreDataPersistanceController sharePersistanceController] fetchAllObjectsWithEntityName:@"Person" finishedBlock:^(NSArray *objs, NSError *error) {
        NSLog(@"array count is %ld error is %@",objs.count,error);
        [self.dataArr addObjectsFromArray:objs];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select");
//    Person *curP = self.dataArr[indexPath.row];
//    curP.name = 2.0000;
//    if ([self.context hasChanges]) {
//        NSLog(@"has changes");
//        [self.context save:nil];
//    }
//    [self refreshData];

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
    cell.textLabel.text = [NSString stringWithFormat:@"%f",person.name];
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
    
    NSMutableArray *datas = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        if (i == 9) {
                    [datas addObject:@{@"name1":@(1.00590),@"sex":@"mmmmm",@"www":@"undifine",@"tetet":@"23423"}];
            continue;
        }
        [datas addObject:@{@"name":@(1.00590),@"sex":@"mmmmm"}];
    }
    
    [[ARCoreDataPersistanceController sharePersistanceController] insertObjectsWithEntityName:[EntityO entityName] attresAndValsArr:datas finishedBlock:^(NSError *error) {
        NSLog(@"insert data finished, error is %@",error);
        [self refreshData];
    }];

    [[ARCoreDataPersistanceController sharePersistanceController] insertObjectsWithEntityName:[Person entityName] attresAndValsArr:datas finishedBlock:^(NSError *error) {
        NSLog(@"insert data finished, error is %@",error);
        [self refreshData];
    }];


    
//    Person *newP = [Person creatNewEntityWithContext:self.context];
//    newP.name = @"jjjjjjjj";
//    newP.sex = @"nan";
//    [self.context save:nil];
//    [self refreshData];
    
}
@end
