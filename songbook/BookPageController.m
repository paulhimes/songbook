//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"
#import "GradientView.h"

@interface BookPageController ()

@property (strong, nonatomic) Book *book;

@end

@implementation BookPageController

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0, 2 * self.view.bounds.size.width, self.view.bounds.size.height)];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:gradientView atIndex:0];
    
    self.view.clipsToBounds = NO;
}

- (NSManagedObject *)modelObject
{
    return self.book;
}

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:self.book.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:40],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSTextEffectAttributeName: NSTextEffectLetterpressStyle}];
}

@end
