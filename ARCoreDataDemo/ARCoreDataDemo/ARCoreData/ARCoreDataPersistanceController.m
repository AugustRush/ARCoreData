//
//  ARCoreDataPersistanceController.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "ARCoreDataPersistanceController.h"

static ARCoreDataPersistanceController *AR__CoreDataPersistanceCtr = nil;

@implementation ARCoreDataPersistanceController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - init methods

/**
 *  单例
 *
 *  @return 静态的CoreDataPersistanceController
 */

+(instancetype)sharePersistanceController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"share");
        AR__CoreDataPersistanceCtr = [[ARCoreDataPersistanceController alloc] init];
    });
    return AR__CoreDataPersistanceCtr;
}

#pragma mark - Custom methods

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)fetchAllObjectsWithEntityName:(NSString *)entityName finishedBlock:(void (^)(NSArray *, NSError *))block
{
    NSEntityDescription *EDes = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    [fetchReq setEntity:EDes];
    
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchReq error:&error];
    block(objects,error);
}

-(void)deleteObjects:(NSSet *)objects finishedBlock:(void (^)(NSError *))block{
    NSError *error;
    [objects enumerateObjectsUsingBlock:^(NSManagedObject *obj, BOOL *stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    [self.managedObjectContext save:&error];
    
    block(error);
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _managedObjectContext = [[NSManagedObjectContext alloc] init];

        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    /**
     *  获取资源文件里面CoreData模型文件数组最后一个
     */
    
    NSURL *modelURL = [[[NSBundle mainBundle] URLsForResourcesWithExtension:@"momd" subdirectory:nil] lastObject];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AR_CoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
