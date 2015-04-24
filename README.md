![](https://github.com/AugustRush/ARCoreData/blob/master/6DB73380-0D9A-43A1-AD21-8374D748429A.png)

* To use CoreData easily .

*****************************************

## Features

* custom primaryKey, currently support NSString , NSInteger(int_64,int_32,int_16..),NSNumber

* JSON(NSDictionary) -> NSManageObject(In theory,support any KVC object)

* JSONs(NSArray) -> NSManageObject(s)

* Safety Mutlie thread

* Easily fetch

* ARTableViewFetchResultController(a convinence class to replace NSFetchResultControler for UITableView)

* ARCollectionViewFetchResultController(a convinence class to replace NSFetchResultControler for UICollectionView)

## Install

#### Manualy
just drag ARCoreData to your project and edit you model , do not need to config any others 
<br>Import: `#import "ARCoreData.h"`

#### Cocoapods
* unsupport currently(will come soon)

## Getting start
***********************

#### Creat new object

if you have a Person and Dog class like this:
```
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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

_____________________


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


```


