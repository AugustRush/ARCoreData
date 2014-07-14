//
//  ARCoreDataPersistanceController.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ARCoreDataPersistanceController : NSObject
{
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong,readonly) NSMutableDictionary *modelEntiysNameAndPropertys;

/**
 *  单例
 *
 *  @return 静态的CoreDataPersistanceController
 */
+(instancetype)sharePersistanceController;

///**
// *  保存数据上下文改变
// */
//- (void)saveContext;

/**
 *  获取某个实体类的所有对象
 *
 *  @param entityName 实体的名字
 *  @param block      获取完成回调
 */
- (void)fetchAllObjectsWithEntityName:(NSString *)entityName finishedBlock:(void(^)(NSArray *objs,NSError *error))block;

/**
 *  删除多个数据对象，形式为NSSet
 *
 *  @param objects 删除的对象集合
 *  @param block   删除操作完成的回调
 */
- (void)deleteObjects:(NSSet *)objects finishedBlock:(void(^)(NSError*))block;

/**
 *  插入一组新对象
 *
 *  @param entityName       实体名称
 *  @param attresAndValsArr 实体的attr和value字典的数组,
    @[@{@"name":@"liu aa",@"sex":@"man"},
      @{@"name":@"wang bb",@"sex":@"women"}]
 *  @param block            插入完成回调
 */
- (void)insertObjectsWithEntityName:(NSString *)entityName attresAndValsArr:(NSArray *)attresAndValsArr finishedBlock:(void(^)(NSError *error))block;

@end