//
//  SimpleSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SimpleSearcher.h"
#import "Section.h"
#import "Song.h"

@implementation SimpleSearcher

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString
                                         inBook:(Book *)book
                                 shouldContinue:(BOOL (^)(void))shouldContinue
{
    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    NSMutableArray *sectionModels = [@[] mutableCopy];
    
    for (Section *section in book.sections) {
        
        NSMutableArray *cellModels = [@[] mutableCopy];
        
        for (Song *song in section.songs) {
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                                 attributes:nil];
            if (song.number) {
                [attributedString appendString:[NSString stringWithFormat:@"%d", [song.number integerValue]]attributes:numberAttributes];
                [attributedString appendString:@" " attributes:titleAttributes];
            }
            
            [attributedString appendString:song.title attributes:titleAttributes];
            
            [cellModels addObject:[[SearchCellModel alloc] initWithSongID:song.objectID content:attributedString range:NSMakeRange(0, 0) asTitleCell:YES]];
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
