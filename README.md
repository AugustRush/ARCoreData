![](https://github.com/AugustRush/ARCoreData/blob/master/6DB73380-0D9A-43A1-AD21-8374D748429A.png)

* ARCoreData is a library to make CoreData easily. we can become a good friend with CoreData now. Don't need any config，just enjoy a high performance object storage。

*****************************************

## Features

###### Primary Key

###### Auto Mapping (attribute，relationship)

###### Multi Thread Safety

###### Async fetch

###### ARTableViewFetchResultController (a convenience class to replace NSFetchResultControler for UITableView)

###### ARCollectionViewFetchResultController (a convenience class to replace NSFetchResultControler for UICollectionView)

## Install

####  Manually
just drag ARCoreData to your project and edit you model , do not need to config any others 
<br>Import: `#import "ARCoreData.h"`

#### Cocoapods
* pod 'ARCoreData', :git => 'https://github.com/AugustRush/ARCoreData.git'

## Getting start
***********************

## Creat a new object

```
+ (id)AR_new;

+ (id)AR_newInContext:(NSManagedObjectContext *)context;

+ (id)AR_newOrUpdateWithJSON:(id)JSON inContext:(NSManagedObjectContext *)context;

+ (NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs inContext:(NSManagedObjectContext *)context;

+ (id)AR_newOrUpdateWithJSON:(id)JSON relationshipMergePolicy:(ARRelationshipMergePolicy)policy inContext:(NSManagedObjectContext *)context;

+ (NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs relationshipsMergePolicy:(ARRelationshipMergePolicy)policy inContext:(NSManagedObjectContext *)context;

```
## Mapping

```
@protocol ARManageObjectMappingProtocol <NSObject>

+(NSDictionary *)JSONKeyPathsByPropertyKey;

@optional
+(NSSet *)uniquedPropertyKeys;

```

you have seen [ARManageObjectMappingProtocol](https://github.com/AugustRush/ARCoreData/blob/master/ARCoreData/Core/ARManageObjectMappingProtocol.h), yes, this protocol has two methods, like famous mapping library <a href="https://github.com/Mantle/Mantle">Mantle</a>, but it must be faster than Mantle. You just need to implement and use these two methods, it will automatically transfrom a JSON(s) or KVC object(s) to NSManageObject(s) instance. Overall, it's very easy and safe.

I have implemented some methods, you can use server response directly to create an(or a array) manageObject(s),
there are some methods you can use to sync JSONs to persistance store (.sqlite):

```
+ (id)AR_newOrUpdateWithJSON:(id)JSON inContext:(NSManagedObjectContext *)context;

+ (NSArray *)AR_newOrUpdateWithJSONs:(NSArray *)JSONs relationshipsMergePolicy:(ARRelationshipMergePolicy)policy inContext:(NSManagedObjectContext *)context;

```

#### Note: you can create a custom mapping for you CoreData model's attribute or relationships like Mantle. Check more details in the demo.

## Fetching objects

```
+(id)AR_anyone;

+(NSArray *)AR_all;

+(NSArray *)AR_whereProperty:(NSString *)property
                     equalTo:(id)value;

+(NSArray *)AR_where:(NSString *)condition,...;

+(NSUInteger)AR_count;

.......

```

Example:
```
    NSArray *allPersons = [Person AR_all];
    
    NSArray *persons = [Person AR_where:@"name = %@",@"a name"];
    
    NSArray *persons = [Person AR_whereProperty:@"guid" equalTo:@3];
```
and so on !!!

## Saving objects

```
* sync
   //NSManageObjectID is thread safety
    [Person AR_saveAndWait:^(NSManagedObjectContext *currentContext) {
        Dog *deleteDog = (Dog *)[currentContext existingObjectWithID:objectID error:nil];
        [currentContext deleteObject:deleteDog];
    }];

* async

[Person AR_save:^(NSManagedObjectContext *currentContext) {
                [Person AR_newOrUpdateWithJSON:@{@"n":name,
                                                 @"g":@"3",
                                                 @"s":@YES,
                                                 @"ds":@[@{@"n":@"123",
                                                           @"g":@{@"uid":@"123",
                                                                  @"extra":@34}},
                                                         @{@"n":name,
                                                           @"g":@{@"uid":@"123",
                                                                  @"extra":@34}}]} inContext:currentContext];
        } completion:^(NSError *error) {
            ARLog(@"all person count is %lu",(unsigned long)[Person AR_count]);
            ARLog(@"all dogs count is %lu",(unsigned long)[Dog AR_count]);
        }];



```
## TODO:

* Migration

* Encryption

## TL;DR:
there have more methods I have created, you can see it in the Demo project after. This library also works in
Swift!




