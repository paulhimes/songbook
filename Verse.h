//
//  Verse.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song, Verse;

@interface Verse : NSManagedObject

@property (nonatomic, retain) NSNumber * isChorus;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * repeatText;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Song *song;
@property (nonatomic, retain) Verse *chorus;

@end
