//
//  SectionPageView.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageView.h"
#import "Section.h"

@interface SectionPageView : TitlePageView

- (instancetype)initWithSection:(Section *)section;

@end
