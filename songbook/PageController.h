//
//  PageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kStandardTextSizeKey;

@protocol PageControllerDelegate;

@interface PageController : UIViewController

@property (nonatomic, readonly) NSManagedObject *modelObject;
@property (nonatomic, weak) id<PageControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, readonly) NSAttributedString *text;

@end

@protocol PageControllerDelegate <NSObject>

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject;
- (void)search;

@end