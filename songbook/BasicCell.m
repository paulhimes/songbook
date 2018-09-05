//
//  BasicCell.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import "BasicCell.h"
#import "songbook-Swift.h"

@implementation BasicCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [Theme grayTrimColor];
    self.selectedBackgroundView = selectedBackgroundView;
    [super setSelected:selected animated:animated];
}

@end
