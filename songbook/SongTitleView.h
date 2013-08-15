//
//  SongTitleView.h
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitleView.h"

@interface SongTitleView : TitleView

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, readonly) CGFloat titleOriginX;

@end
