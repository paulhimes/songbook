//
//  ContextCell.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import "ContextCell.h"
#import "songbook-Swift.h"

@interface ContextCell()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) NSAttributedString *originalAttributedText;
@property (weak, nonatomic) IBOutlet UILabel *hiddenSpacerLabel;
@property (weak, nonatomic) IBOutlet UIView *spacerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hideSpacerConstraint;

@end

@implementation ContextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(preferredSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(preferredSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)setContentLabel:(UILabel *)contentLabel
{
    [_contentLabel removeObserver:self forKeyPath:@"bounds"];
    _contentLabel = contentLabel;
    [_contentLabel addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setHiddenSpacerLabel:(UILabel *)hiddenSpacerLabel
{
    _hiddenSpacerLabel = hiddenSpacerLabel;
    [self updateSpacerViewForCurrentSizeCategory];
}

- (void)setHideSpacerConstraint:(NSLayoutConstraint *)hideSpacerConstraint
{
    _hideSpacerConstraint = hideSpacerConstraint;
    [self updateSpacerViewForCurrentSizeCategory];
}

- (void)updateSpacerViewForCurrentSizeCategory
{
    if (self.hideSpacerConstraint == nil || self.hiddenSpacerLabel == nil) {
        return;
    }
    
    if (UIContentSizeCategoryIsAccessibilityCategory(UIApplication.sharedApplication.preferredContentSizeCategory)) {
        if (![self.hiddenSpacerLabel.constraints containsObject:self.hideSpacerConstraint]) {
            [self.hiddenSpacerLabel addConstraint:self.hideSpacerConstraint];
        }
    } else {
        [self.hiddenSpacerLabel removeConstraint:self.hideSpacerConstraint];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [Theme grayTrimColor];
    self.selectedBackgroundView = selectedBackgroundView;
    [super setSelected:selected animated:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.contentLabel) {
        self.contentLabel.attributedText = [self textForWidth:self.contentLabel.bounds.size.width];
    }
}

- (void)preferredSizeCategoryDidChange:(NSNotification *)notification
{
    [self updateSpacerViewForCurrentSizeCategory];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentLabel.attributedText = [self textForWidth:self.contentLabel.bounds.size.width];
}

- (void)dealloc
{
    [self.contentLabel removeObserver:self forKeyPath:@"bounds"];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _originalAttributedText = attributedText;
    self.contentLabel.attributedText = [self textForWidth:self.contentLabel.bounds.size.width];
    self.hiddenSpacerLabel.font = [Theme fontForTextStyle:UIFontTextStyleHeadline];
}

- (NSAttributedString *)textForWidth:(CGFloat)width
{
    // Scale the original attributed text fonts based on the current preferred size category.
    NSMutableAttributedString *scaledText = [[NSMutableAttributedString alloc] initWithAttributedString:self.originalAttributedText];
    [scaledText enumerateAttributesInRange:NSMakeRange(0, scaledText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        UIFont *originalFont = attrs[NSFontAttributeName];
        UIFont *scaledFont = [[UIFontMetrics defaultMetrics] scaledFontForFont:originalFont];
        [scaledText addAttribute:NSFontAttributeName value:scaledFont range:range];
    }];
    
    CGRect possibleFittedTextBoundingRect = CGRectMake(0, 0, 0, 0);
    NSUInteger searchRangeStart = 0;
    NSAttributedString *fittedText = [[NSAttributedString alloc] init];
    NSMutableAttributedString *possibleFittedText = [[NSMutableAttributedString alloc] init];
    
    // As long as the possible fitted text is not larger than the desired width.
    while (possibleFittedTextBoundingRect.size.width <= width) {
        // Save the possible fitted text to return.
        fittedText = [possibleFittedText copy];
        
        // Stop early if we run out of words from the source text.
        if (searchRangeStart >= scaledText.length) {
            break;
        }
        
        // Find the next ignored segment in the source text. Ignore segments containing only whitespace, punctuation, and digits. This should be at the end of the next word.
        NSRange rangeOfFirstIgnoredSegment = [scaledText.string rangeOfString:@"[\\s\\d\\p{P}]+" options:NSRegularExpressionSearch range:NSMakeRange(searchRangeStart, scaledText.length - searchRangeStart)];
        
        if (rangeOfFirstIgnoredSegment.location == NSNotFound) {
            // If no more words were found, just try to use the whole source text.
            possibleFittedText = [scaledText mutableCopy];
            // Set the search range past the end of the source text, this will cause the search to stop at the beginning of the next round.
            searchRangeStart = scaledText.length;
        } else if (rangeOfFirstIgnoredSegment.location == 0) {
            // If the source text started with in ignored segment, continue looking for additional words a the end of this segment.
            searchRangeStart = rangeOfFirstIgnoredSegment.location + rangeOfFirstIgnoredSegment.length;
        } else {
            // If an additional word was found, set the possible text to everything up through this word.
            possibleFittedText = [[scaledText attributedSubstringFromRange:NSMakeRange(0, rangeOfFirstIgnoredSegment.location)] mutableCopy];
            // Add an ellipsis to the end of the possible text because we did not use the complete source text.
            NSDictionary<NSAttributedStringKey, id> *attributesOfNextCharacter = [scaledText attributesAtIndex:rangeOfFirstIgnoredSegment.location effectiveRange:nil];
            [possibleFittedText appendString:@"…" attributes:attributesOfNextCharacter];
            // Continue looking for additional words a the end of this ignored segment.
            searchRangeStart = rangeOfFirstIgnoredSegment.location + rangeOfFirstIgnoredSegment.length;
        }
        
        // Calcualte the bounding rect of the new possible fitted text.
        possibleFittedTextBoundingRect = [possibleFittedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:nil];
    }

    return fittedText;
}

@end
