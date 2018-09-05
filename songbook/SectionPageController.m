//
//  SectionPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//

#import "SectionPageController.h"
#import "Section+Helpers.h"
#import "songbook-Swift.h"

@interface SectionPageController ()

@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (nonatomic, readonly) Section *section;

@end

@implementation SectionPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.view.backgroundColor = [Theme paperColor];
    self.textView.backgroundColor = [Theme paperColor];
}

- (id<SongbookModel>)modelObject
{
    return self.section;
}

- (Section *)section
{
    Section *section;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:nil];
    if ([managedObject isKindOfClass:[Section class]]) {
        section = (Section *)managedObject;
    }
    return section;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    CGFloat limitedStandardTextSize = MIN(25, standardTextSize);

    return [[NSAttributedString alloc] initWithString:self.section.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithDynamicName:[Theme normalFontName] size:limitedStandardTextSize * 2],
                                                        NSForegroundColorAttributeName: [Theme textColor]
                                                        }];
}

@end
