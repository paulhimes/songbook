//
//  CoreDataStack.h
//  songbook
//
//  Created by Paul Himes on 11/2/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CoreDataStack : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSURL *databaseDirectory;

- (instancetype)initWithFileURL:(NSURL *)fileURL concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
