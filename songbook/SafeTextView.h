//
//  SafeTextView.h
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SafeTextView : UITextView

@property (nonatomic) BOOL contentOffsetCallsAllowed;

- (void)forceContentOffset:(CGPoint)contentOffset;
- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex; // Returns a point relative to text view's frame.
- (NSUInteger)glyphIndexClosestToPoint:(CGPoint)point; //  Point is relative to text view's frame.

@end
