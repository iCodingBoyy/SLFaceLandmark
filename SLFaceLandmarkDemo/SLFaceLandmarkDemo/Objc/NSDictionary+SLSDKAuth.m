//
//  NSDictionary+SLSDKAuth.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "NSDictionary+SLSDKAuth.h"

BOOL SSAIsValidKeyInDict(id object, NSString *key) {
    if (!object || !key) return NO;
    if (![object isKindOfClass:[NSDictionary class]]) return NO;
    NSDictionary *dict = (NSDictionary*)object;
    return [dict.allKeys containsObject:key];
}

id SSASafeValue(id value, Class class) {
    if (class == NULL) return value;
    if (value) return value;
    NSString *className = NSStringFromClass(class);
    if ([className isEqualToString:NSStringFromClass([NSString class])]) {
        return @"";
    }
    else if ([className isEqualToString:NSStringFromClass([NSNumber class])]) {
        return @(0);
    }
    else if  ([className isEqualToString:NSStringFromClass([NSDictionary class])]) {
        return @{};
    }
    else if  ([className isEqualToString:NSStringFromClass([NSArray class])]) {
        return @[];
    }
    return value;
}

NSString *SSAStringForKeyInDict(id object, NSString *key)  {
    if (!SSAIsValidKeyInDict(object, key)) return nil;
    NSDictionary *dict = (NSDictionary*)object;
    id value = dict[key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    else if (value && [value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)value stringValue];
    }
    return nil;
}

NSString *SSASafeStringForKeyInDict(id object, NSString *key) {
    NSString *value = SSAStringForKeyInDict(object, key);
    return value ? value : @"";
}

NSNumber *SSANumberForKeyInDict(id object, NSString *key) {
    if (!SSAIsValidKeyInDict(object, key)) return nil;
    NSDictionary *dict = (NSDictionary*)object;
    id value = dict[key];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    else if (value && [value isKindOfClass:[NSString class]]) {
        NSString *string = (NSString*)value;
        if ([string rangeOfString:@"."].location != NSNotFound) {
            return @(string.floatValue);
        }
        else {
            return @(string.integerValue);
        }
    }
    return nil;
}

NSNumber *SSASafeNumberForKeyInDict(id object, NSString *key) {
    NSNumber *value = SSANumberForKeyInDict(object, key);
    return value ? value : @(0);
}

NSInteger SSAIntegerForKeyInDict(id object, NSString *key) {
    if (!SSAIsValidKeyInDict(object, key)) return 0;
    NSDictionary *dict = (NSDictionary*)object;
    id value = dict[key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString*)value integerValue];
    }
    else if (value && [value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)value integerValue];
    }
    return 0;
}


NSArray *SSAArrayForKeyInDict(id object, NSString *key) {
    if (!SSAIsValidKeyInDict(object, key)) return nil;
    NSDictionary *dict = (NSDictionary*)object;
    id value = dict[key];
    if (value && [value isKindOfClass:[NSArray class]]) {
        return (NSArray*)value;
    }
    return nil;
}

NSArray *SSASafeArrayForKeyInDict(id object, NSString *key) {
    NSArray *value = SSAArrayForKeyInDict(object, key);
    return value ? value : @[];
}




NSDictionary *SSADictionaryForKeyInDict(id object, NSString *key) {
    if (!SSAIsValidKeyInDict(object, key)) return nil;
    NSDictionary *dict = (NSDictionary*)object;
    id value = dict[key];
    if (value && [value isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)value;
    }
    return nil;
}

NSDictionary *SSASafeDictionaryForKeyInDict(id object, NSString *key) {
    NSDictionary *value = SSADictionaryForKeyInDict(object, key);
    return value ? value : @{};
}

@implementation NSDictionary (SLSDKAuth)

@end

@implementation NSMutableDictionary (SLSDKAuth)
- (void)SSASafeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}
@end

static NSString *SSALocalAndServerTimeDifferencekey = @"SSALocalAndServerTimeDifferencekey";

BOOL SSASaveTimeDifferenceBetweenServerAndLocal(NSTimeInterval timeInterval) {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:@(timeInterval) forKey:SSALocalAndServerTimeDifferencekey];
    return [standardUserDefaults synchronize];
}

NSTimeInterval SSAGetServerAndLocalTimeDifference(void)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [standardUserDefaults objectForKey:SSALocalAndServerTimeDifferencekey];
    if (value) {
        return value.doubleValue;
    }
    return 0;
}
