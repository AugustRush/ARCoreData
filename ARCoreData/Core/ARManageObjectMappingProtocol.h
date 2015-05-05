//
//  ARManageObjectMapping.h
//  ARCoreDataDemo
//
//  Created by August on 15/4/19.
//  Copyright (c) 2015年 lPW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ARRelationshipMergePolicy) {
    ARRelationshipMergePolicyAdd,//default
    ARRelationshipMergePolicyRepalce
};

@protocol ARManageObjectMappingProtocol <NSObject>

+(NSDictionary *)JSONKeyPathsByPropertyKey;

@optional
+(NSString *)primaryKey;

@end
