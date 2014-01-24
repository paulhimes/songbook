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
- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex;
- (CGFloat)contentHeight;

@end
