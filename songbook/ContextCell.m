//
//  ContextCell.m
//  songbook
//
//  Created by Paul Himes on 8/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "ContextCell.h"

@implementation ContextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
