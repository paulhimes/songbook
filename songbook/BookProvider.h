//
//  BookProvider.h
//  songbook
//
//  Created by Paul Himes on 1/8/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataStack.h"

@interface BookProvider : UIActivityItemProvider

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack includeExtraFiles:(BOOL)includeExtraFiles;

@end
