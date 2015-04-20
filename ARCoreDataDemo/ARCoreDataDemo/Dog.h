//
//  Dog.h
//  ARCoreDataDemo
//
//  Created by August on 15/4/18.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ARCoreData.h"

@class Person;

@interface Dog : NSManagedObject<ARManageObjectMappingProtocol>

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int64_t guid;
@property (nonatomic, retain) NSSet *owners;
@end

@interface Dog (CoreDataGeneratedAccessors)

- (void)addOwnersObject:(Person *)value;
- (void)removeOwnersObject:(Person *)value;
- (void)addOwners:(NSSet *)values;
- (void)removeOwners:(NSSet *)values;

@end
