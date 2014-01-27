//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"
#import "GradientView.h"
#import "BookCodec.h"

@interface BookPageController () <UIToolbarDelegate>

@property (nonatomic, readonly) Book *book;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation BookPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0, 2 * self.view.bounds.size.width, self.view.bounds.size.height)];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:gradientView atIndex:0];
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbar.delegate = self;
}

- (NSManagedObject *)modelObject
{
    return self.book;
}

- (Book *)book
{
    Book *book;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:NULL];
    if ([managedObject isKindOfClass:[Book class]]) {
        book = (Book *)managedObject;
    }
    return book;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    return [[NSAttributedString alloc] initWithString:self.book.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:standardTextSize * 2],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]
                                                        }];
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
