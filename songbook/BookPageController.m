//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"
#import "GradientView.h"
#import "Book+Helpers.h"

@interface BookPageController ()

@property (nonatomic, readonly) Book *book;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;

@end

@implementation BookPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:gradientView atIndex:0];
    
    UIImage *clearImage = [[UIImage alloc] init];
    [self.bottomBar setBackgroundImage:clearImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomBar setShadowImage:clearImage forToolbarPosition:UIBarPositionAny];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.bottomBar invalidateIntrinsicContentSize];
}

- (void)updateThemedElements
{
    self.bottomBar.tintColor = [Theme paperColor];
}

- (id<SongbookModel>)modelObject
{
    return self.book;
}

- (Book *)book
{
    Book *book;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:nil];
    if ([managedObject isKindOfClass:[Book class]]) {
        book = (Book *)managedObject;
    }
    return book;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.book.title]
                                                                             attributes:@{NSFontAttributeName: [UIFont fontWithName:[Theme normalFontFamily] size:standardTextSize * 2.5],
                                                                                          NSForegroundColorAttributeName: [Theme paperColor]
                                                                                          }];
    [text appendString:[NSString stringWithFormat:@"Version %@", self.book.version]
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:standardTextSize * 0.75],
                         NSForegroundColorAttributeName: [[Theme paperColor] colorWithAlphaComponent:0.5]
                         }];

    return text;
}

- (UIColor *)pageControlColor
{
    return [Theme paperColor];
}

@end
