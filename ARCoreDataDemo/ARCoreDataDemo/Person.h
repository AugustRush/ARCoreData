//
//  Person.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-4.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * name;
@property (nonatomic, retain) NSNumber * qwe;
@property (nonatomic, retain) NSNumber * qweqwe;
@property (nonatomic, retain) NSString * qweqweqw;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * tq;

@end
