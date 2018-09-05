//
//  SearchTableModel.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//

#import <Foundation/Foundation.h>

@interface SearchTableModel : NSObject

@property (nonatomic, readonly) NSArray *sectionModels;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;

- (instancetype)initWithSectionModels:(NSArray *)sectionModels
           persistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

@end
