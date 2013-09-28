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

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString inBook:(Book *)book
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
            
            [cellModels addObject:[[SearchCellModel alloc] initWithSongID:song.objectID content:attributedString location:0 asTitleCell:YES]];
        }
        
        [sectionModels addObject:[[SearchSectionModel alloc] initWithTitle:section.title cellModels:cellModels]];
    }
    
    SearchTableModel *table = [[SearchTableModel alloc] initWithSectionModels:[sectionModels copy]];
    
    return table;
}

@end
