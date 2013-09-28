//
//  SearchSectionModel.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchSectionModel : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *cellModels;

- (instancetype)initWithTitle:(NSString *)title
                   cellModels:(NSArray *)cellModels;

@end
