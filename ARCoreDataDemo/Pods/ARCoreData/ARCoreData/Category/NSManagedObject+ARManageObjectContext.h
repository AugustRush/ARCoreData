//
//  NSManagedObject+ARManageObjectContext.h
//  Board
//
//  Created by August on 15/3/20.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ARManageObjectContext)
/**
 *  get the persitanceController default private context
 *
 *  @return the private context
 */
+(NSManagedObjectContext *)defaultPrivateContext;

/**
 *  get the persistanceContoller default main context
 *
 *  @return the main context
 */
+(NSManagedObjectContext *)defaultMainContext;

@end
