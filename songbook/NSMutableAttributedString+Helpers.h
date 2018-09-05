//
//  NSMutableAttributedString+Helpers.h
//  songbook
//
//  Created by Paul Himes on 8/14/13.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Helpers)

- (void)appendString:(NSString *)str attributes:(NSDictionary *)attrs;
- (void)addAttributes:(NSDictionary *)attributes toFirstOccurrenceOfString:(NSString *)searchString;

@end
