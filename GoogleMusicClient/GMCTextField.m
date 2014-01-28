//
//  GMCTextField.m
//  Google Music Client
//
//  Created by Arthur Jamain on 27/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import "GMCTextField.h"

@implementation GMCTextField

static NSEvent *keyEvent = nil;

- (BOOL)isCharacterLetter:(NSString *) character
{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    return [[character stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
}

- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    [self setStringValue:@""];
    if (okToChange) {
        [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
        if (!keyEvent) {
            keyEvent =  [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
                displayText = @"";
                NSUInteger modifiers = [event modifierFlags];
                
                if (modifiers & NSCommandKeyMask) {
                    displayText = [displayText stringByAppendingString:@"command "];
                }
                if (modifiers & NSControlKeyMask) {
                    displayText = [displayText stringByAppendingString:@"ctrl "];
                }
                if (modifiers & NSAlternateKeyMask) {
                    displayText = [displayText stringByAppendingString:@"alt "];
                }
                if (modifiers & NSShiftKeyMask) {
                    displayText = [displayText stringByAppendingString:@"shift "];
                }
                displayText = [displayText stringByAppendingString:[event characters]];
                
                NSLog(@"%@", displayText);
                
                return event;
                
            }];
            
        }
    }
    return okToChange;
}

- (void)keyUp:(NSEvent *)theEvent
{
// WHY ?? =(
//    NSLog(@"%@", displayText);
//    [self setStringValue:displayText];
}


@end
