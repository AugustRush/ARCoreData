//
//  NSManagedObject+ARCreate.h
//  Board
//
//  Created by August on 15/3/18.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ARCreate)

/**
 *  creat an entity in mainQueue context
 *
 *  @return entity
 */
+(id)AR_newInMain;
/**
 *  creat an entity in mainQueue context
 *
 *  @return entity
 */
+(id)AR_new;

/**
 *  creat an new entity in your context
 *
 *  @param context your context
 *
 *  @return entity
 */
+(id)AR_newInContext:(NSManagedObjectContext *)context;


@end
