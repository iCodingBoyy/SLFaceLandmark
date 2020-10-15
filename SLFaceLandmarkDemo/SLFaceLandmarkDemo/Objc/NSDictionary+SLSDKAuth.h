
//
//  NSDictionary+SLSDKAuth.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 将value转换为安全值，如果value为nil，则返回对应类型的空值，如果@""、@(0)、@[]、@{}
/// @warning 仅对NSString、NSNumber、NSDictionary、NSArray等类型有效
FOUNDATION_EXPORT id SSASafeValue(id value, Class class);

FOUNDATION_EXPORT BOOL SSAIsValidKeyInDict(id object, NSString *key);

FOUNDATION_EXPORT NSInteger SSAIntegerForKeyInDict(id object, NSString *key);

FOUNDATION_EXPORT NSString *SSAStringForKeyInDict(id object, NSString *key);

/// @discussion不存在则返回非nil安全值`@""`;
FOUNDATION_EXPORT NSString *SSASafeStringForKeyInDict(id object, NSString *key);

FOUNDATION_EXPORT NSNumber *SSANumberForKeyInDict(id object, NSString *key);

/// @discussion 如果不存在，则返回非nil安全值`@(0)`
FOUNDATION_EXPORT NSNumber *SSASafeNumberForKeyInDict(id object, NSString *key);

FOUNDATION_EXPORT NSArray *SSAArrayForKeyInDict(id object, NSString *key);

FOUNDATION_EXPORT NSArray *SSASafeArrayForKeyInDict(id object, NSString *key);



@interface NSDictionary (SLSDKAuth)

@end

@interface NSMutableDictionary (SLSDKAuth)
- (void)SSASafeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;
@end

FOUNDATION_EXPORT NSTimeInterval SSAGetServerAndLocalTimeDifference(void);
FOUNDATION_EXPORT BOOL SSASaveTimeDifferenceBetweenServerAndLocal(NSTimeInterval timeInterval);
