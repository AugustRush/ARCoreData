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
* pod 'ARCoreData', :git => 'https://github.com/AugustRush/ARCoreData.git'

## Getting start
***********************

## Creat new object

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

@class Person;

@interface Dog : NSManagedObject

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
you can create a person like this:

```
    Person *person = [Person AR_new];
    person.name = @"aaa";
    person.guid = @"1";
    
    Dog *pet = [Dog AR_new];
    pet.name = @"doggie";
    pet.guid = 123;

    [person addDogsObject:pet];

    [Person AR_saveAndWait];//this is save method

```

if you want to use a JSON(KVC object) create a new person , you should impliment <ARManageObjectMappingProtocol>, 
this is my Person and Dog .m file.

```
@implementation Person

@dynamic name;
@dynamic sex;
@dynamic guid;
@dynamic dogs;

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"guid":@"g",
             @"name":@"n",
             @"sex":@"s",
             @"dogs":@"ds"};
}

+(NSString *)primaryKey
{
    return @"guid";
}

@end


**********************************


@implementation Dog

@dynamic name;
@dynamic owners;
@dynamic guid;

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"name":@"n",
             @"owners":@"o",
             @"guid":@"g.uid"};
}

+(NSString *)primaryKey
{
    return @"guid";
}

@end

```

and then, you can create a Person like this:

```
        Person *person = [Person AR_newOrUpdateWithJSON:@{@"n":name,
                                                @"g":@"3",
                                                @"s":@YES,
                                                @"ds":@[@{@"n":@"haha",
                                                          @"g":@{@"uid":@"7",
                                                                 @"extra":@34}},
                                                        @{@"n":name,
                                                          @"g":@{@"uid":@"6",
                                                                 @"extra":@34}}]}];
```

if you impliment the class method +(NSString *)primaryKey; you just can create a uniqued person through a same "guid".

## Mapping (ARManageObjectMappingProtocol)

```
@protocol ARManageObjectMappingProtocol <NSObject>

+(NSDictionary *)JSONKeyPathsByPropertyKey;

@optional
+(NSString *)primaryKey;

@end
```

i hava impliment some methods , you can use server response directly to create an(or a array) manageObject(s),
there have methods :

```
+(id)AR_newOrUpdateWithJSON:(NSDictionary *)JSON;

+(NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs;

```
you have seen ARManageObjectMappingProtocol , yes ,this protocol have two methods,like famous mapping library <a href="https://github.com/Mantle/Mantle">Mantle</a>, but this transform must be faster than Mantle.

## Fetch objects

there have a lot of methods to help you fetch objects convinience and faster , exemple:
```
    NSArray *allPersons = [Person AR_all];
    
    NSArray *persons = [Person AR_where:@"name = %@",@"a name"];
    
    NSArray *persons = [Person AR_whereProperty:@"guid" equalTo:@3];
```
and so on !!!

## Saving objects

```
* sync
    [Person AR_saveAndWait];

    [Person AR_saveAndWaitCompletion:^(BOOL success, NSError *error) {
        // fetch objects or do UI work
    }];

* async

	[Person AR_saveCompletion:^(BOOL success, NSError *error) {
        NSLog(@"all dog is %@ dog count is %ld",[Dog AR_all],[Dog AR_count]);
        
        NSLog(@"all person is %@ dog count is %ld",[Person AR_all],[Person AR_count]);
    }];


``` 
##TL;DR:
there have more methods i have created for you, you can see it in my Demo project after. this library also worked in
swift fine !




