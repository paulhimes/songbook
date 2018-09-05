//
//  SuperScrollIndicator.h
//  songbook
//
//  Created by Paul Himes on 2/16/14.
//

#import <UIKit/UIKit.h>

@protocol SuperScrollIndicatorDelegate;

@interface SuperScrollIndicator : UIView

@property (nonatomic, weak) id<SuperScrollIndicatorDelegate> delegate;

- (void)scrollToPercent:(CGFloat)percent;
- (void)setScrollViewContentHeight:(CGFloat)scrollViewContentHeight andFrameHeight:(CGFloat)scrollViewFrameHeight;

@end

@protocol SuperScrollIndicatorDelegate <NSObject>

- (void)superScrollIndicator:(SuperScrollIndicator *)superScrollIndicator didScrollToPercent:(CGFloat)percent;

@end
