//
//  PinchAnchor.m
//  songbook
//
//  Created by Paul Himes on 9/8/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PinchAnchor.h"

@interface PinchAnchor()

@property (nonatomic) CGFloat percentDownSubview;
@property (nonatomic) CGFloat yCoordinateInScrollView;

@end

@implementation PinchAnchor

- (instancetype)initWithScrollViewYCoordinate:(CGFloat)yCoordinateInScrollView
                           percentDownSubview:(CGFloat)percentDownSubview
{
    self = [super init];
    if (self) {
        self.yCoordinateInScrollView = yCoordinateInScrollView;
        self.percentDownSubview = percentDownSubview;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"PinchAnchor [ScrollView Y Coordinate %f; Subview percent down %f]", self.yCoordinateInScrollView, self.percentDownSubview];
}

@end
