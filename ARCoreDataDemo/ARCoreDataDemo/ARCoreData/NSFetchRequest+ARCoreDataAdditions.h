//
//  NSFetchRequest+ARCoreDataAdditions.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14/7/14.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchRequest (ARCoreDataAdditions)

/**
 *  初始化一个有批处理数量限制的查询请求
 *
 *  @param batchSize         批处理数量值
 *  @param entityDescription coredata实体的描述
 *
 *  @return coredata条件查询请求对象
 */
+(NSFetchRequest *)fetchReuqestWithBatchSize:(NSUInteger)batchSize entityDescription:(NSEntityDescription *)entityDescription;

@end
