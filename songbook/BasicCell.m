//
//  BasicCell.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import "BasicCell.h"
#import "songbook-Swift.h"

@interface BasicCell()

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@end

@implementation BasicCell

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

- (void)setStackView:(UIStackView *)stackView
{
    _stackView = stackView;
    [self updateStackViewForCurrentSizeCategory];
}

- (void)updateStackViewForCurrentSizeCategory
{
    if (UIContentSizeCategoryIsAccessibilityCategory(UIApplication.sharedApplication.preferredContentSizeCategory)) {
        self.stackView.axis = UILayoutConstraintAxisVertical;
        self.stackView.alignment = UIStackViewAlignmentLeading;
        self.stackView.spacing = 0;
    } else {
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        self.stackView.alignment = UIStackViewAlignmentFirstBaseline;
        self.stackView.spacing = 10;
    }
}

- (void)setNumberLabel:(UILabel *)numberLabel
{
    _numberLabel = numberLabel;
    [self updateNumberLabelForCurrentSizeCategory];
}

- (void)updateNumberLabelForCurrentSizeCategory
{
    if (UIContentSizeCategoryIsAccessibilityCategory(UIApplication.sharedApplication.preferredContentSizeCategory)) {
        self.numberLabel.textAlignment = NSTextAlignmentNatural;
    } else {
        self.numberLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)preferredSizeCategoryDidChange:(NSNotification *)notification
{
    [self updateStackViewForCurrentSizeCategory];
    [self updateNumberLabelForCurrentSizeCategory];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [Theme grayTrimColor];
    self.selectedBackgroundView = selectedBackgroundView;
    [super setSelected:selected animated:animated];
}

@end
