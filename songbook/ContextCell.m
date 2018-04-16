//
//  ContextCell.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "ContextCell.h"
#import "songbook-Swift.h"

@interface ContextCell()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) NSAttributedString *attributedText;

@end

@implementation ContextCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [Theme grayTrimColor];
    self.selectedBackgroundView = selectedBackgroundView;
    
    [self.contentLabel addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.contentLabel) {
        self.contentLabel.attributedText = [self textForWidth:self.contentLabel.bounds.size.width];
    }
}

- (void)dealloc
{
    [self.contentLabel removeObserver:self forKeyPath:@"bounds"];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText = attributedText;
    self.contentLabel.attributedText = [self textForWidth:self.contentLabel.bounds.size.width];
}

- (NSAttributedString *)textForWidth:(CGFloat)width
{
    CGRect possibleFittedTextBoundingRect = CGRectMake(0, 0, 0, 0);
    NSUInteger searchRangeStart = 0;
    NSAttributedString *fittedText = [[NSAttributedString alloc] init];
    NSMutableAttributedString *possibleFittedText = [[NSMutableAttributedString alloc] init];
    
    // As long as the possible fitted text is not larger than the desired width.
    while (possibleFittedTextBoundingRect.size.width <= width) {
        // Save the possible fitted text to return.
        fittedText = [possibleFittedText copy];
        
        // Stop early if we run out of words from the source text.
        if (searchRangeStart >= self.attributedText.length) {
            break;
        }
        
        // Find the next ignored segment in the source text. Ignore segments containing only whitespace, punctuation, and digits. This should be at the end of the next word.
        NSRange rangeOfFirstIgnoredSegment = [self.attributedText.string rangeOfString:@"[\\s\\d\\p{P}]+" options:NSRegularExpressionSearch range:NSMakeRange(searchRangeStart, self.attributedText.length - searchRangeStart)];
        
        if (rangeOfFirstIgnoredSegment.location == NSNotFound) {
            // If no more words were found, just try to use the whole source text.
            possibleFittedText = [self.attributedText mutableCopy];
            // Set the search range past the end of the source text, this will cause the search to stop at the beginning of the next round.
            searchRangeStart = self.attributedText.length;
        } else if (rangeOfFirstIgnoredSegment.location == 0) {
            // If the source text started with in ignored segment, continue looking for additional words a the end of this segment.
            searchRangeStart = rangeOfFirstIgnoredSegment.location + rangeOfFirstIgnoredSegment.length;
        } else {
            // If an additional word was found, set the possible text to everything up through this word.
            possibleFittedText = [[self.attributedText attributedSubstringFromRange:NSMakeRange(0, rangeOfFirstIgnoredSegment.location)] mutableCopy];
            // Add an ellipsis to the end of the possible text because we did not use the complete source text.
            NSDictionary<NSAttributedStringKey, id> *attributesOfLastCharacter = [possibleFittedText attributesAtIndex:possibleFittedText.length - 1 effectiveRange:nil];
            [possibleFittedText appendString:@"…" attributes:attributesOfLastCharacter];
            // Continue looking for additional words a the end of this ignored segment.
            searchRangeStart = rangeOfFirstIgnoredSegment.location + rangeOfFirstIgnoredSegment.length;
        }
        
        // Calcualte the bounding rect of the new possible fitted text.
        possibleFittedTextBoundingRect = [possibleFittedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:nil];
    }

    return fittedText;
}

@end
