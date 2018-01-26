//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kModelIDURLKey = @"ModelIDURLKey";
static NSString * const kDelegateKey = @"DelegateKey";
static NSString * const kHighlightRangeKey = @"HighlightRangeKey";
static NSString * const kBookmarkedGlyphIndexKey = @"BookmarkedGlyphIndexKey";
static NSString * const kBookmarkedGlyphYOffsetKey = @"BookmarkedGlyphYOffsetKey";

const float kSuperMaximumStandardTextSize = 60;
const float kMaximumStandardTextSize = 60;
const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.restorationClass = [self class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.attributedText = self.text;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.textView.clipsToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    
    [coder encodeObject:[self.modelID URIRepresentation] forKey:kModelIDURLKey];
    
    if (self.delegate) {
        [coder encodeObject:self.delegate forKey:kDelegateKey];
    }
    
    [coder encodeObject:[NSValue valueWithRange:self.highlightRange] forKey:kHighlightRangeKey];
    
    [coder encodeObject:@(self.bookmarkedGlyphIndex) forKey:kBookmarkedGlyphIndexKey];
    [coder encodeDouble:self.bookmarkedGlyphYOffset forKey:kBookmarkedGlyphYOffsetKey];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    PageController *controller;
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    CoreDataStack *coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    NSURL *modelIDURL = [coder decodeObjectForKey:kModelIDURLKey];
    NSManagedObjectID *modelID = [coreDataStack.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:modelIDURL];
    id<PageControllerDelegate> delegate = [coder decodeObjectForKey:kDelegateKey];
    NSRange highlightRange = [[coder decodeObjectForKey:kHighlightRangeKey] rangeValue];
    NSUInteger bookmarkedGlyphIndex = [[coder decodeObjectForKey:kBookmarkedGlyphIndexKey] unsignedIntegerValue];
    CGFloat bookmarkedGlyphYOffset = [coder decodeDoubleForKey:kBookmarkedGlyphYOffsetKey];
    
    if (storyboard && coreDataStack && modelID && delegate) {
        controller = (PageController *)[storyboard instantiateViewControllerWithIdentifier:[identifierComponents lastObject]];
        controller.coreDataStack = coreDataStack;
        controller.modelID = modelID;
        controller.delegate = delegate;
        controller.highlightRange = highlightRange;
        controller.bookmarkedGlyphIndex = bookmarkedGlyphIndex;
        controller.bookmarkedGlyphYOffset = bookmarkedGlyphYOffset;
    }
    
    return controller;
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSUserDefaultsDidChangeNotification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self textContentChanged];
        });
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

- (UIColor *)pageControlColor
{
    return [Theme redColor];
}

@end
