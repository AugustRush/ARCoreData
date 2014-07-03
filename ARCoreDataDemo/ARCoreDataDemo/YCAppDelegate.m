//
//  YCAppDelegate.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "YCAppDelegate.h"
#import "ARCoreData.h"
#import "Person.h"

@implementation YCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    ARCoreDataPersistanceController *defCoreDataCtr = [ARCoreDataPersistanceController sharePersistanceController];
    
    int i = 0;
    
    do{
        Person *newPerson = [Person creatNewEntityWithContext:defCoreDataCtr.managedObjectContext];
        newPerson.name = i;
        newPerson.sex = @"hah";
        newPerson.tq = @";akdjiqnkdvlqndvoqsdnvsdnvsafvfnv";
        newPerson.qweqwe = YES;
        
        i++;
    }while (i < 3);
    [defCoreDataCtr.managedObjectContext save:nil];
    /**
     *  fetch request
     */
    
//    NSEntityDescription *EDes = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:defCoreDataCtr.managedObjectContext];
//    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
//    [fetchReq setEntity:EDes];
//    
//    NSError *error;
//    NSArray *objects = [defCoreDataCtr.managedObjectContext executeFetchRequest:fetchReq error:&error];
//    if (objects == nil) {
//        NSLog(@"fetch error is %@",error);
//    }else{
//        NSLog(@"objecs is %@",objects);
//    }
    
//    [defCoreDataCtr fetchAllObjectsWithEntityName:[Person entityName]];
//
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
