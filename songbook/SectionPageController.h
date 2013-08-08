//
//  SectionPageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "Section.h"

@interface SectionPageController : PageController

- (instancetype)initWithSection:(Section *)section;
- (Section *)section;

@end
