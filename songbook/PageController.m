//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "BookCodec.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

const float kSuperMaximumStandardTextSize = 60;
const float kMaximumStandardTextSize = 40;
const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) NSString *temporaryExportFilePath;

@end

@implementation PageController

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGesture:)];
    }
    return _pinchGestureRecognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.attributedText = self.text;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.textView.clipsToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSUserDefaultsDidChangeNotification]) {
        [self textContentChanged];
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

#pragma mark - Action Methods
- (IBAction)searchAction:(UIButton *)sender
{
    [self.delegate search];
}

- (IBAction)exportAction:(UIButton *)sender
{
    self.temporaryExportFilePath = [BookCodec exportBook];
    NSData *exportData = [NSData dataWithContentsOfFile:self.temporaryExportFilePath];
    
    // Email the file data.
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:[[self.temporaryExportFilePath lastPathComponent] stringByDeletingPathExtension]];
    [mailController addAttachmentData:exportData
                             mimeType:@"application/vnd.paulhimes.songbook.songbook"
                             fileName:[self.temporaryExportFilePath lastPathComponent]];
    [self presentViewController:mailController animated:YES completion:^{}];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    // Delete the temporary file.
    if ([self.temporaryExportFilePath length] > 0) {
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:self.temporaryExportFilePath error:&deleteError];
    }
    self.temporaryExportFilePath = nil;

}

@end
