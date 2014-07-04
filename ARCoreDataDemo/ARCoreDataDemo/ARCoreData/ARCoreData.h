//
//  ARCoreData.h
//  ARCoreDataDemo
//
//  Created by 刘平伟 on 14-7-1.
//  Copyright (c) 2014年 lPW. All rights reserved.
//

#ifndef ARCoreDataDemo_ARCoreData_h
#define ARCoreDataDemo_ARCoreData_h

#import "ARCoreDataPersistanceController.h"
#import "NSManagedObject+ARCoreDataAdditions.h"

#endif

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif
