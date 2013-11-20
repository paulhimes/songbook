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

@interface BookPageController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSURL *temporaryExportFile;
@property (nonatomic, readonly) Book *book;

@end

@implementation BookPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0, 2 * self.view.bounds.size.width, self.view.bounds.size.height)];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:gradientView atIndex:0];
}

- (NSManagedObject *)modelObject
{
    return self.book;
}

- (Book *)book
{
    Book *book;
    NSError *getBookError;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:&getBookError];
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
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
//                                                        NSTextEffectAttributeName: NSTextEffectLetterpressStyle
                                                        }];
}

- (IBAction)exportAction:(UIButton *)sender
{
    self.temporaryExportFile = [BookCodec exportBookFromContext:self.coreDataStack.managedObjectContext];
    NSData *exportData = [NSData dataWithContentsOfURL:self.temporaryExportFile];
    
    // Email the file data.
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:[[self.temporaryExportFile lastPathComponent] stringByDeletingPathExtension]];
    [mailController addAttachmentData:exportData
                             mimeType:@"application/vnd.paulhimes.songbook.songbook"
                             fileName:[self.temporaryExportFile lastPathComponent]];
    [self presentViewController:mailController animated:YES completion:^{}];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    // Delete the temporary file.
    if (self.temporaryExportFile) {
        NSError *deleteError;
        if (![[NSFileManager defaultManager] removeItemAtURL:self.temporaryExportFile error:&deleteError]) {
            NSLog(@"Failed to delete temporary export file: %@", deleteError);
        }
    }
    self.temporaryExportFile = nil;
    
}

@end
