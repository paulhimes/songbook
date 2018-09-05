//
//  NSMutableAttributedString+Helpers.m
//  songbook
//
//  Created by Paul Himes on 8/14/13.
//

#import "NSMutableAttributedString+Helpers.h"

@implementation NSMutableAttributedString (Helpers)

- (void)appendString:(NSString *)str attributes:(NSDictionary *)attrs
{
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attrs]];
}

- (void)addAttributes:(NSDictionary *)attributes toFirstOccurrenceOfString:(NSString *)searchString
{
    NSRange range = [self.string rangeOfString:searchString
                                       options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttributes:attributes range:range];
    }
}

@end
