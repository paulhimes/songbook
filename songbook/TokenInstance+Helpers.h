//
//  TokenInstance+Helpers.h
//  songbook
//
//  Created by Paul Himes on 9/16/13.
//

#import "TokenInstance.h"

@interface TokenInstance (Helpers)

+ (TokenInstance *)instanceOfToken:(Token *)token
                           atRange:(NSRange)range
                            inSong:(Song *)song;

@end
