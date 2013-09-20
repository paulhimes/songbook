//
//  Token.h
//  songbook
//
//  Created by Paul Himes on 9/16/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
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
