//
//  SearchHeaderFooterView.m
//  songbook
//
//  Created by Paul Himes on 1/18/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "SearchHeaderFooterView.h"

@interface SearchHeaderFooterView() <UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation SearchHeaderFooterView

- (UIToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _toolbar.barTintColor = [Theme grayTrimColor];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = self.toolbar;
        self.textLabel.textColor = [Theme paperColor];
    }
    return self;
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionAny;
}

@end
