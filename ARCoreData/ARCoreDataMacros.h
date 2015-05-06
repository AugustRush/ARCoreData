//
//  ARCoreDataMacros.h
//  ARCoreDataDemo
//
//  Created by August on 15/4/19.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#ifndef ARCoreDataDemo_ARCoreDataMacros_h
#define ARCoreDataDemo_ARCoreDataMacros_h

#define _systermVersion_greter_8_0 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

#ifdef DEBUG
#define NSLog(format, ...) \
    do { \
    NSLog(@"<%@ : %d : %s>-: %@", \
    [[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
    __LINE__, \
    __FUNCTION__, \
    [NSString stringWithFormat:format, ##__VA_ARGS__]); \
    } while(0)
#else
#define NSLog(...)
#endif


#endif
