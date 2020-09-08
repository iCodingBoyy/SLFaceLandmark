//
//  SLSDKAuthDefine.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString * SLSDKAuthDomain;


typedef NSString *SLSDKAuthContextOption NS_EXTENSIBLE_STRING_ENUM;
typedef NSDictionary<SLSDKAuthContextOption, id> SLSDKAuthContext;
typedef NSMutableDictionary<SLSDKAuthContextOption, id> SLSDKAuthMutableContext;

FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextAppIdKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextAppSecretKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextAppTypeKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextUUIDKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextOsVersionKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextPhoneTypeKey;
FOUNDATION_EXPORT SLSDKAuthContextOption const SLSDKAuthContextSDKVersionKey;


typedef NS_ENUM(NSInteger, SLSDKAuthErrorCode) {
    SLSDKAuthErrorCodeUnknown = 10010,  ///< 未知错误码
    SLSDKAuthErrorInvalidParamter, ///< 空的参数
    SLSDKAuthErrorInvalidRspData, ///< 无效的响应数据
    SLSDKAuthErrorInvalidRspDict, ///< 无效的响应数据格式
    SLSDKAuthErrorInvalidRspKeyValues, ///< 错误的相应字段
    SLSDKAuthErrorEmptyDataInRspDict, ///< 空的响应数据
};

#ifdef __SLLOG__ 
    #define SSALOG(...) NSLog(__VA_ARGS__)
#else
    #define SSALOG(...) NSLog(__VA_ARGS__)
#endif

@interface SLSDKAuthDefine : NSObject

@end
