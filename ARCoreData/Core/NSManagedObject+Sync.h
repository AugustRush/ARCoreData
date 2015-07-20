//
//  NSManagedObject+Sync.h
//  Pods
//
//  Created by August on 15/6/10.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Sync)

+(void)syncWithJSONs:(NSArray *)JSONs completion:(void(^)(NSArray *objects))completion;

@end
