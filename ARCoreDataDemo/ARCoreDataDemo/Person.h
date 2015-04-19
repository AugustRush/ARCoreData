//
//  Person.h
//  ARCoreDataDemo
//
//  Created by August on 15/4/18.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ARCoreData.h"

@class Dog;

@interface Person : NSManagedObject<ARManageObjectMappingProtocol>

@property (nonatomic, retain) NSString * name;
@property (nonatomic) BOOL sex;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet *dogs;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addDogsObject:(Dog *)value;
- (void)removeDogsObject:(Dog *)value;
- (void)addDogs:(NSSet *)values;
- (void)removeDogs:(NSSet *)values;

@end
