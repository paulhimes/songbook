//
//  SearchTitleCellModel.h
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import <Foundation/Foundation.h>
#import "SearchCellModel.h"

@interface SearchTitleCellModel : NSObject <SearchCellModel>

@property (nonatomic, readonly) NSManagedObjectID *songID;
@property (nonatomic) NSUInteger number;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                        number:(NSUInteger)number
                         title:(NSString *)title;

@end
