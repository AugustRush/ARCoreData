//
//  ARCoreDataPersistanceController.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface ARCoreDataPersistanceController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSMutableDictionary *modelEntiysNameAndPropertys;

+(instancetype)sharePersistanceController;

-(NSManagedObjectContext *)mainManageObjectContext;

#if DEBUG
-(void)removeAllRecord;
#endif

@end