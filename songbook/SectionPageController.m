//
//  SectionPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SectionPageController.h"

@interface SectionPageController ()

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic, readonly) Section *section;

@end

@implementation SectionPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *searchButtonImage = [[self.searchButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *searchButtonHighlightedImage = [[self.searchButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setImage:searchButtonImage forState:UIControlStateNormal];
    [self.searchButton setImage:searchButtonHighlightedImage forState:UIControlStateHighlighted];
}

- (NSManagedObject *)modelObject
{
    return self.section;
}

- (Section *)section
{
    Section *section;
    NSError *getSectionError;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:&getSectionError];
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
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:standardTextSize * 1.75]}];
}

@end
