//
//  SongbookTextView.m
//  songbook
//
//  Created by Paul Himes on 8/19/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookTextView.h"

@interface SongbookTextView()


@end

@implementation SongbookTextView

- (void)layoutSubviews
{
    CGPoint savedBoundsOrigin = self.bounds.origin;
    [super layoutSubviews];
    [self resetBoundsIfNeededToOrigin:savedBoundsOrigin];
    NSLog(@"SongbookTextView layoutSubviews %@", [self textFragment]);
}

- (NSString *)textFragment
{
    NSString *string = self.text;
    
    if ([string length] > 15) {
        string = [string substringToIndex:15];
    }
    
    return string;
}

//- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
//{
//    [super setContentOffset:contentOffset animated:animated];
//    NSLog(@"SongbookTextView setContentOffset:Animated %@", [self textFragment]);
//}
//
//- (void)setContentOffset:(CGPoint)contentOffset
//{
//    [super setContentOffset:contentOffset];
//    NSLog(@"SongbookTextView setContentOffset: %@ %@", NSStringFromCGPoint(contentOffset), [self textFragment]);
//}

- (void)setBounds:(CGRect)bounds
{
    NSLog(@"SongbookTextView setBounds %@ %@", NSStringFromCGRect(bounds), [self textFragment]);
    [super setBounds:bounds];
}

- (void)setFrame:(CGRect)frame
{
    NSLog(@"SongbookTextView setFrame %@ %@", NSStringFromCGRect(frame), [self textFragment]);
    CGPoint savedBoundsOrigin = self.bounds.origin;
    [super setFrame:frame];
    [self resetBoundsIfNeededToOrigin:savedBoundsOrigin];
}

- (void)setContentSize:(CGSize)contentSize
{
    contentSize = CGSizeMake(contentSize.width, MAX(self.bounds.size.height + 44, contentSize.height));
    [super setContentSize:contentSize];
    NSLog(@"SongbookTextView setContentSize %@ %@", NSStringFromCGSize(contentSize), [self textFragment]);
}

- (void)resetBoundsIfNeededToOrigin:(CGPoint)origin
{
    if (!CGPointEqualToPoint(self.bounds.origin, origin)) {
        NSLog(@"overriding bounds %@", NSStringFromCGRect(self.bounds));
        self.bounds = CGRectMake(origin.x, origin.y, self.bounds.size.width, self.bounds.size.height);
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate scrollViewDidScroll:self];
        }
    }
}

@end
