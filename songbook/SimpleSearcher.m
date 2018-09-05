//
//  SimpleSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/26/13.
//

#import "SimpleSearcher.h"
#import "Section.h"
#import "Song.h"

@implementation SimpleSearcher

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString
                                         inBook:(Book *)book
                                 shouldContinue:(BOOL (^)(void))shouldContinue
{
    NSMutableArray *sectionModels = [@[] mutableCopy];
    
    for (Section *section in book.sections) {
        
        NSMutableArray *cellModels = [@[] mutableCopy];
        
        NSArray *songs = [section.songs array];
        
//        songs = [songs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            Song *song1 = (Song *)obj1;
//            Song *song2 = (Song *)obj2;
//            return [song1.title compare:song2.title options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
//        }];
        
        for (Song *song in songs) {
            SearchTitleCellModel *cellModel = [[SearchTitleCellModel alloc] initWithSongID:song.objectID
                                                                                    number:[song.number unsignedIntegerValue]
                                                                                     title:song.title];
            
            [cellModels addObject:cellModel];
        }
        
        // Only show the section if it contains cells.
        if ([cellModels count]) {
            [sectionModels addObject:[[SearchSectionModel alloc] initWithTitle:section.title cellModels:cellModels]];
        }
    }
    
    SearchTableModel *table = [[SearchTableModel alloc] initWithSectionModels:[sectionModels copy] persistentStoreCoordinator:book.managedObjectContext.persistentStoreCoordinator];
    
    return table;
}

@end
