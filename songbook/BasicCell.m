//
//  BasicCell.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
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
