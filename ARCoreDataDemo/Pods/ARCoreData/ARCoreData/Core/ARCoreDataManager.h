//
//  ARCoreDataManager.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ARCoreDataManager : NSObject

@property (readonly, nonatomic, strong) NSManagedObjectContext *privateContext;
@property (readonly, nonatomic, strong) NSManagedObjectContext *mainContext;

@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)shareManager;

-(void)removeAllRecord;

@end