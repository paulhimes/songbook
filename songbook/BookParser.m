//
//  BookParser.m
//  songbook
//
//  Created by Paul Himes on 9/9/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookParser.h"
#import "Book.h"

@implementation BookParser

- (Book *)bookFromFilePath:(NSString *)path
{
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileString = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
    
    NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        
    }
    
    
    NSLog(@"%@", fileString);
    
    return nil;
}

@end
