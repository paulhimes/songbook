//
//  TokenInstance.h
//  songbook
//
//  Created by Paul Himes on 9/19/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song, Token;

@interface TokenInstance : NSManagedObject

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) Song *song;
@property (nonatomic, retain) Token *token;
@property (nonatomic, retain) TokenInstance *nextInstance;
@property (nonatomic, retain) TokenInstance *previousInstance;

@end
