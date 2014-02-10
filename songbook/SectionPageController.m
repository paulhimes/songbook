//
//  SectionPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SectionPageController.h"
#import "Section.h"

@interface SectionPageController () <UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, readonly) Section *section;

@end

@implementation SectionPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbar.delegate = self;
    
    self.view.backgroundColor = [Theme paperColor];
    self.textView.backgroundColor = [Theme paperColor];
}

- (NSManagedObject *)modelObject
{
    return self.section;
}

- (Section *)section
{
    Section *section;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:NULL];
    if ([managedObject isKindOfClass:[Section class]]) {
        section = (Section *)managedObject;
    }
    return section;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    return [[NSAttributedString alloc] initWithString:self.section.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:standardTextSize * 1.75],
                                                        NSForegroundColorAttributeName: [Theme textColor]
                                                        }];
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
