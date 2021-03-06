//
//  TmuxStateParser.m
//  iTerm
//
//  Created by George Nachman on 11/30/11.
//  Copyright (c) 2011 Georgetech. All rights reserved.
//

#import "TmuxStateParser.h"

NSString *kStateDictInAlternateScreen = @"in_alternate_screen";
NSString *kStateDictBaseCursorX = @"base_cursor_x";
NSString *kStateDictBaseCursorY = @"base_cursor_y";
NSString *kStateDictCursorX = @"cursor_x";
NSString *kStateDictCursorY = @"cursor_y";
NSString *kStateDictScrollRegionUpper = @"scroll_region_upper";
NSString *kStateDictScrollRegionLower = @"scroll_region_lower";
NSString *kStateDictTabstops = @"tabstops";
NSString *kStateDictDECSCCursorX = @"decsc_cursor_x";
NSString *kStateDictDECSCCursorY = @"decsc_cursor_y";

@interface NSString (TmuxStateParser)
- (NSArray *)intlistValue;
- (NSNumber *)numberValue;
@end

@implementation NSString (TmuxStateParser)

- (NSNumber *)numberValue
{
    return [NSNumber numberWithInt:[self intValue]];
}

- (NSArray *)intlistValue
{
    NSArray *components = [self componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *s in components) {
        [result addObject:[NSNumber numberWithInt:[s intValue]]];
    }
    return result;
}

@end

@implementation TmuxStateParser

+ (TmuxStateParser *)sharedInstance
{
    static TmuxStateParser *instance;
    if (!instance) {
        instance = [[TmuxStateParser alloc] init];
    }
    return instance;
}

- (NSMutableDictionary *)parsedStateFromString:(NSString *)layout
{
    // State is a collection of key-value pairs. Each KVP is delimited by
    // newlines. The key is to the left of the first =, the value is to the
    // right.
    NSString *intType = @"numberValue";
    NSString *uintType = @"numberValue";
    NSString *intlistType = @"intlistValue";

    NSDictionary *fieldTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                intType, kStateDictInAlternateScreen,
                                uintType, kStateDictBaseCursorX,
                                uintType, kStateDictBaseCursorY,
                                uintType, kStateDictCursorX,
                                uintType, kStateDictCursorY,
                                uintType, kStateDictScrollRegionUpper,
                                uintType, kStateDictScrollRegionLower,
                                intlistType, kStateDictTabstops,
                                intType, kStateDictDECSCCursorX,
                                intType, kStateDictDECSCCursorY,
                                nil];

    NSArray *fields = [layout componentsSeparatedByString:@"\n"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *kvp in fields) {
        NSRange eq = [kvp rangeOfString:@"="];
        if (eq.location != NSNotFound) {
            NSString *key = [kvp substringToIndex:eq.location];
            NSString *value = [kvp substringFromIndex:eq.location + 1];
            NSString *converter = [fieldTypes objectForKey:key];
            if (converter) {
                SEL sel = NSSelectorFromString(converter);
                id convertedValue = [value performSelector:sel];
                [result setObject:convertedValue forKey:key];
            } else {
                [result setObject:value forKey:key];
            }
        } else {
            NSLog(@"Bogus result in dump-state: \"%@\"", kvp);
        }
    }
    return result;
}


@end
