//
//  SongPageController.h
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageController.h"
#import "Song.h"

@interface SongPageController : PageController

- (instancetype)initWithSong:(Song *)song;
- (Song *)song;

@end
