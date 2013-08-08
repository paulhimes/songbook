//
//  SongPageView.h
//  songbook
//
//  Created by Paul Himes on 8/1/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageView.h"
#import "Song.h"

@interface SongPageView : PageView

- (instancetype)initWithSong:(Song *)song;

@end
