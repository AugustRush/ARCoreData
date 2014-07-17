//
//  ARCoreDataPersistanceController.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "ARCoreDataPersistanceController.h"

static ARCoreDataPersistanceController *AR__CoreDataPersistanceCtr = nil;

@interface ARCoreDataPersistanceController ()

@end

@implementation ARCoreDataPersistanceController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - init methods

-(id)init
{
    self = [super init];
    if (self) {
        _modelEntiysNameAndPropertys = [NSMutableDictionary dictionary];
    }
    return self;
}

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
//    NSEntityDescription *EDes = [NSEntityDescription entityForName:entityName
//                                            inManagedObjectContext:self.managedObjectContext];
//    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
//    [fetchReq setEntity:EDes];
    NSAssert(block, @"finished block should not be nil");
    NSAssert(entityName, @"entityName should not be nil");
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchReq error:&error];
    block(objects,error);
}

-(void)fetchObjectsWithFetchRequest:(NSFetchRequest *)fetchRequest finishedBlock:(void (^)(NSArray *, NSError *))block{
    NSAssert(block, @"finished block should not be nil");
    NSAssert(fetchRequest, @"fetchRequest should not be nil");
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    block(objects,error);
}

-(void)deleteObjects:(NSSet *)objects finishedBlock:(void (^)(NSError *))block
{
    NSAssert(objects.count > 0, @"objects count should not equal to 0");
    NSAssert(block, @"finished block should not be nil");
    NSError *error;
    [objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    [self.managedObjectContext save:&error];
    
    block(error);
}

-(void)insertObjectsWithEntityName:(NSString *)entityName attresAndValsArr:(NSArray *)attresAndValsArr finishedBlock:(void (^)(NSError *))block
{
    NSAssert(block, @"finished block should not be nil");
    NSAssert(entityName, @"entityName should not be nil");
    NSAssert(attresAndValsArr, @"attresAndValsArr should not be nil");
    NSError *error;
    __block NSArray *allPropertys = nil;
    [attresAndValsArr enumerateObjectsUsingBlock:^(NSDictionary *attresAndVals, NSUInteger idx, BOOL *stop) {
        NSManagedObject *newObj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        if (allPropertys == nil) {
            allPropertys = _modelEntiysNameAndPropertys[entityName];
        }
        [attresAndVals enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([allPropertys containsObject:key]) {
                [newObj setValue:obj forKey:key];
            }else{
                NSLog(@"attresAndValsArr index %ld compoment has't key %@",(unsigned long)idx,key);
            }
        }];
        
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
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];//创建一个似有的线程队列，不会阻塞UI

        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSDictionary *entitysNameAndDes = [_managedObjectModel entitiesByName];
    [entitysNameAndDes enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSEntityDescription * obj, BOOL *stop) {
        [_modelEntiysNameAndPropertys setObject:obj.propertiesByName.allKeys forKey:key];
    }];
    NSLog(@"model entity name and pro is %@",_modelEntiysNameAndPropertys);
    
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
    
    NSDictionary *persistentStoreOptions = @{ // Light migration
                                             NSInferMappingModelAutomaticallyOption:@YES,
                                             NSMigratePersistentStoresAutomaticallyOption:@YES
                                             };
    
    NSPersistentStore *persistanceStore = [_persistentStoreCoordinator
                                           addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil
                                           URL:storeURL
                                           options:persistentStoreOptions
                                           error:&error];
    
    if (!persistanceStore) {

        NSLog(@"persistance store may has changed");
        error = nil;
        if ([self removeSQLiteFilesAtStoreURL:storeURL error:&error]) {
            persistanceStore = [_persistentStoreCoordinator
                                addPersistentStoreWithType:NSSQLiteStoreType
                                configuration:nil
                                URL:storeURL
                                options:persistentStoreOptions
                                error:&error];
        }else{
            NSLog(@"could not remove has changed sqilte");
        }
    }
    
    return _persistentStoreCoordinator;
}

- (BOOL)removeSQLiteFilesAtStoreURL:(NSURL *)storeURL error:(NSError * __autoreleasing *)error {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeDirectory = [storeURL URLByDeletingLastPathComponent];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:storeDirectory
                                          includingPropertiesForKeys:nil
                                                             options:0
                                                        errorHandler:nil];
    
    NSString *storeName = [storeURL.lastPathComponent stringByDeletingPathExtension];
    for (NSURL *url in enumerator) {
        
        if ([url.lastPathComponent hasPrefix:storeName] == NO) {
            continue;
        }
        
        NSError *fileManagerError = nil;
        if ([fileManager removeItemAtURL:url error:&fileManagerError] == NO) {
            
            if (error != NULL) {
                *error = fileManagerError;
            }
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
