//
//  Person.m
//  ARCoreDataDemo
//
//  Created by August on 15/4/18.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#import "Person.h"
#import "Dog.h"


@implementation Person

@dynamic name;
@dynamic sex;
@dynamic guid;
@dynamic dogs;
@dynamic birthday;

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"guid":@"g",
             @"name":@"n",
             @"sex":@"s",
             @"birthday":@"birth",
             @"dogs":@"ds"};
}

+(NSString *)primaryKey
{
    return @"guid";
}

// the custom property transform methods, just add "Transformer" before property name, exmple,
// +(NSDate *)timeTransformer:(id)value;
// +(NSArray *)dogsTransformer:(id)value;

+(NSDate *)birthdayTransformer:(id)value
{
    return [NSDate dateWithTimeIntervalSince1970:12352345];
}

@end
