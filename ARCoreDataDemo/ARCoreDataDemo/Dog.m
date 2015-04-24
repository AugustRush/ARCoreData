//
//  Dog.m
//  ARCoreDataDemo
//
//  Created by August on 15/4/18.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#import "Dog.h"
#import "Person.h"


@implementation Dog

@dynamic name;
@dynamic owners;

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"name":@"n",
             @"owners":@"o"};
}

+(NSString *)primaryKey
{
    return @"name";
}

@end