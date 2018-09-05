//
//  SafeTextView.h
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//

#import <UIKit/UIKit.h>

@interface SafeTextView : UITextView

@property (nonatomic) BOOL contentOffsetCallsAllowed;

- (void)forceContentOffset:(CGPoint)contentOffset;
- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex; // Returns a point relative to text view's frame.
- (NSUInteger)glyphIndexClosestToPoint:(CGPoint)point; //  Point is relative to text view's frame.
- (CGFloat)distanceFromLastLineTopToContainerBottomForCharactersInRange:(NSRange)characterRange; // The distance from the top of the last line in the given character range to the bottom ot the text view's text container.

@end
