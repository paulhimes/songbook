//
//  SearchCellModel.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchCellModel <NSObject>

@property (nonatomic, readonly) NSManagedObjectID *songID;
@property (nonatomic, readonly) NSRange range;

@end
