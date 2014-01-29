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

- (BOOL)resignFirstResponder {
    NSLog(@"yogerger");
    [NSEvent removeMonitor:keyEvent];
    keyEvent = nil;
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    [self setStringValue:@""];
    NSLog(@"yoyoyo");
    if (okToChange) {
        if (!keyEvent) {
            keyEvent =  [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
                displayText = @"";
                NSMutableDictionary *shortcut = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *modifierDic = [[NSMutableDictionary alloc] init];
                NSUInteger modifiers = [event modifierFlags];
                
                if (modifiers & NSCommandKeyMask) {
                    displayText = [displayText stringByAppendingString:@"cmd +"];
                    [modifierDic setValue:[[NSString alloc] initWithFormat:@"%d", cmdKey] forKey:@"cmd"];
                }
                if (modifiers & NSControlKeyMask) {
                    displayText = [displayText stringByAppendingString:@"ctrl +"];
                    [modifierDic setValue:[[NSString alloc] initWithFormat:@"%d", controlKey] forKey:@"ctrl"];
                }
                if (modifiers & NSAlternateKeyMask) {
                    displayText = [displayText stringByAppendingString:@"alt +"];
                    [modifierDic setValue:[[NSString alloc] initWithFormat:@"%d", optionKey] forKey:@"alt"];
                }
                if (modifiers & NSShiftKeyMask) {
                    displayText = [displayText stringByAppendingString:@"shift +"];
                    [modifierDic setValue:[[NSString alloc] initWithFormat:@"%d", shiftKey] forKey:@"shift"];
                }
                displayText = [displayText stringByAppendingString:[event characters]];
                
                [shortcut setValue:modifierDic forKey:@"modifiers"];
                [shortcut setValue:[[NSString alloc] initWithFormat:@"%d", [event keyCode]] forKey:@"key"];
                [shortcut setValue:displayText forKey:@"printableKey"];
                
            
                
                [[self delegate] setShortcut: shortcut];
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
