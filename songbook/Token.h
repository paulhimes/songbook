//
//  Token.h
//  songbook
//
//  Created by Paul Himes on 9/22/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TokenInstance;

@interface Token : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *instances;
@end

@interface Token (CoreDataGeneratedAccessors)

- (void)addInstancesObject:(TokenInstance *)value;
- (void)removeInstancesObject:(TokenInstance *)value;
- (void)addInstances:(NSSet *)values;
- (void)removeInstances:(NSSet *)values;

@end
