//
//  TokenInstance+Helpers.h
//  songbook
//
//  Created by Paul Himes on 9/16/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TokenInstance.h"

@interface TokenInstance (Helpers)

+ (TokenInstance *)instanceOfToken:(Token *)token
                           atRange:(NSRange)range
                            inSong:(Song *)song;

@end
