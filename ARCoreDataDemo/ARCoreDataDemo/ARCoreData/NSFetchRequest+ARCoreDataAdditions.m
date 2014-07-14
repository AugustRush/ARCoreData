//
//  NSFetchRequest+ARCoreDataAdditions.m
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14/7/14.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import "NSFetchRequest+ARCoreDataAdditions.h"

@implementation NSFetchRequest (ARCoreDataAdditions)


//
+(NSFetchRequest *)fetchReuqestWithBatchSize:(NSUInteger)batchSize entityDescription:(NSEntityDescription *)entityDescription
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchBatchSize:batchSize];
    return request;
}

@end
