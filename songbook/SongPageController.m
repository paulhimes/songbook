//
//  SongPageController.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongPageController.h"
#import "SongPageView.h"

@interface SongPageController ()

@property (strong, nonatomic) Song *song;

@end

@implementation SongPageController

- (instancetype)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        self.song = song;
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.song;
}

- (PageView *)buildPageView
{
    return [[SongPageView alloc] initWithSong:self.song];
}

- (void)setTitleVisible:(BOOL)visible
{
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (visible) {
        CGFloat fontSize = 20;
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineHeightMultiple = 1.3;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSMutableDictionary *attributes = [@{
                                             NSFontAttributeName: [UIFont fontWithName:@"Marion" size:fontSize],
                                             NSParagraphStyleAttributeName: paragraphStyle
                                             } mutableCopy];
        
        NSMutableDictionary *numberAttributes = [attributes mutableCopy];
        numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:fontSize];
        
        if (self.song.number) {
            NSString *numberString = [NSString stringWithFormat:@"%d", [self.song.number unsignedIntegerValue]];
            NSString *string = [NSString stringWithFormat:@"%@ %@", numberString, self.song.title];
            
            attributedTitle = [[NSMutableAttributedString alloc] initWithString:string
                                                                     attributes:attributes];
            
            [attributedTitle setAttributes:numberAttributes
                                     range:[string rangeOfString:numberString]];
        } else {
            attributedTitle = [[NSMutableAttributedString alloc] initWithString:self.song.title
                                                                     attributes:attributes];
        }
    }
    
    [self.delegate pageController:self contentTitleChangedTo:[attributedTitle copy]];
}

@end
