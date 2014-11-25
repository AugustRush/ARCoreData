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

@property (nonatomic, strong) NSManagedObjectContext *mainManageObjectContext;

@property (nonatomic, strong) NSManagedObjectContext *defaultPrivateQueueContext;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mainManageObjectContextDidSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self mainManageObjectContext]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(privateManageObjectContextDidSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self managedObjectModel]];

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


#pragma mark - notification methods

-(void)mainManageObjectContextDidSaved:(NSNotification *)notification
{
    @synchronized(self){
        [self.managedObjectContext performBlock:^{
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

-(void)privateManageObjectContextDidSaved:(NSNotification *)notification
{
    @synchronized(self){
        [self.mainManageObjectContext performBlock:^{
            [self.mainManageObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
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

#pragma mark - Core Data stack

-(NSManagedObjectContext *)mainManageObjectContext
{
    if (_mainManageObjectContext != nil) {
        return _mainManageObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainManageObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManageObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_mainManageObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _mainManageObjectContext;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
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
    
    NSDictionary *persistentStoreOptions = [self persistentStoreOptions];
    
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

- (NSDictionary *)persistentStoreOptions
{
    return @{NSInferMappingModelAutomaticallyOption: @YES,
             NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
