//
//  PSUnicodeUtilities.m
//  PsyScopeEditor
//
//  Created by James on 17/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

#import "PSUnicodeUtilities.h"
@import CoreServices;
@import Carbon;

@implementation PSUnicodeUtilities

+(NSString*)characterForEventWithoutModifiers:(NSEvent*)event {
    
    
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    CGEventFlags flags = 0;
    UInt32 modifierKeyState = (flags >> 16) & 0xFF;
    
    const size_t unicodeStringLength = 4;
    UniChar unicodeString[unicodeStringLength];
    UniCharCount realLength;
    UInt32 deadKeyState = 0;
    
    UCKeyTranslate(keyboardLayout,
                   [event keyCode],
                   kUCKeyActionDown,
                   modifierKeyState,
                   LMGetKbdType(),
                   0,
                   &deadKeyState,
                   unicodeStringLength,
                   &realLength,
                   unicodeString);
    //CFRelease(currentKeyboard);
    
    
    CFStringRef string = CFStringCreateWithCharacters(kCFAllocatorDefault, unicodeString, realLength);
    return (__bridge NSString *)string;
}


@end
