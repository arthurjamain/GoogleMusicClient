//
//  GMCWindow.m
//  GoogleMusicClient
//
//  Created by Arthur Jamain on 23/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import "GMCWindow.h"

@implementation GMCWindow


- (BOOL)windowShouldClose:(id)sender {
    
    [self orderOut:self];
    return NO;
    
}
@end
