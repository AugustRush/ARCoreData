//
//  ARCoreDataManager.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "ARCoreDataManager.h"

@interface ARCoreDataManager ()

@property (nonatomic, strong) NSURL *storeUrl;
@property (nonatomic, strong) NSPersistentStore *persistentStore;

@end

@implementation ARCoreDataManager
@synthesize privateContext = _privateContext;
@synthesize mainContext = _mainContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - init methods

-(id)init
{
    self = [super init];
    if (self) {
        [self addNotifications];
    }
    return self;
}

+(instancetype)shareManager
{
    static ARCoreDataManager *AR__CoreDataPersistanceCtr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AR__CoreDataPersistanceCtr = [[ARCoreDataManager alloc] init];
    });
    return AR__CoreDataPersistanceCtr;
}


#pragma mark - merge notification methods

-(void)mainManageObjectContextDidSaved:(NSNotification *)notification
{
    @synchronized(self){
        [self.privateContext performBlock:^{
            [self.privateContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

-(void)privateManageObjectContextDidSaved:(NSNotification *)notification
{
    @synchronized(self){
        [self.mainContext performBlock:^{
//http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
            NSLog(@"merge info is %@",notification.userInfo);
        for(NSManagedObject *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
            [[self.mainContext objectWithID:[object objectID]] willAccessValueForKey:nil];
        }
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Custom methods

-(void)removeAllRecord
{
    NSError *error = nil;
    NSPersistentStoreCoordinator *storeCoodinator = self.persistentStoreCoordinator;
    [storeCoodinator removePersistentStore:self.persistentStore error:&error];
    
    [self removeNotifications];
    _privateContext = nil;
    _mainContext = nil;
    if ([self removeSQLiteFilesAtStoreURL:self.storeUrl error:&error]) {
        self.persistentStore = [self.persistentStoreCoordinator
                            addPersistentStoreWithType:NSSQLiteStoreType
                            configuration:nil
                            URL:self.storeUrl
                            options:[self persistentStoreOptions]
                            error:&error];
        [self addNotifications];
    }
    
    NSLog(@"remove store file error is %@",error);
}

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainManageObjectContextDidSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[self mainContext]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privateManageObjectContextDidSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[self privateContext]];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data stack

-(NSManagedObjectContext *)mainContext
{
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_mainContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)privateContext
{
    if (_privateContext != nil) {
        return _privateContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_privateContext setPersistentStoreCoordinator:coordinator];
    }
    return _privateContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BoardCoreData.sqlite"];
    self.storeUrl = storeURL;
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *persistentStoreOptions = [self persistentStoreOptions];
    
    NSPersistentStore *persistanceStore = [_persistentStoreCoordinator
                                           addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil
                                           URL:storeURL
                                           options:persistentStoreOptions
                                           error:&error];
    
    self.persistentStore = persistanceStore;
    
    if (!persistanceStore) {

        NSLog(@"persistance store may has changed");
        error = nil;
        if ([self removeSQLiteFilesAtStoreURL:storeURL error:&error]) {
            self.persistentStore = [_persistentStoreCoordinator
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
             NSSQLitePragmasOption: @{@"synchronous": @"NO"}};
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
