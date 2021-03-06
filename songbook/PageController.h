//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//

#import <UIKit/UIKit.h>
#import "SafeTextView.h"
#import "CoreDataStack.h"
#import "SongbookModel.h"

extern NSString * const kStandardTextSizeKey;
extern const float kSuperMaximumStandardTextSize;
extern const float kMaximumStandardTextSize;
extern const float kMinimumStandardTextSize;

@protocol PageControllerDelegate;

@interface PageController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) NSManagedObjectID *modelID;
@property (nonatomic, readonly) id<SongbookModel> modelObject;
@property (nonatomic, weak) id<PageControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet SafeTextView *textView;
@property (nonatomic, readonly) NSAttributedString *text;
@property (nonatomic) NSRange highlightRange;
@property (nonatomic) NSNumber *bookmarkedGlyphIndex;
@property (nonatomic) NSNumber *bookmarkedGlyphYOffset;
@property (nonatomic, readonly) UIColor *pageControlColor;

- (void)handleGesture:(UIPinchGestureRecognizer *)sender;
- (void)textContentChanged;
- (void)updateThemedElements;

@end

@protocol PageControllerDelegate <NSObject>

- (void)pageController:(PageController *)pageController
   selectedModelObject:(id<SongbookModel>)modelObject;
- (CoreDataStack *)coreDataStack;

@end
