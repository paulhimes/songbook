//
//  PinchAnchor.h
//  songbook
//
//  Created by Paul Himes on 9/8/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinchAnchor : NSObject

@property (nonatomic, readonly) CGFloat percentDownSubview;
@property (nonatomic, readonly) CGFloat yCoordinateInScrollView;

- (instancetype)initWithScrollViewYCoordinate:(CGFloat)yCoordinateInScrollView
                           percentDownSubview:(CGFloat)percentDownSubview;

@end
