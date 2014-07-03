//
//  Person.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-3.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic) float name;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * tq;
@property (nonatomic) int16_t qwe;
@property (nonatomic) BOOL qweqwe;
@property (nonatomic, retain) NSString * qweqweqw;

@end
