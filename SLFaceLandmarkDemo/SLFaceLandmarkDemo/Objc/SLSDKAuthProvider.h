//
//  SLSDKAuthProvider.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/1.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SLAuthorizationState) {
    SLAuthorizationStateUnknown,
    SLAuthorizationStateAuthDataError,
    SLAuthorizationStateRSAVerifyFailed,
    SLAuthorizationStateUnAuthorized,
    SLAuthorizationStateAuthorized,
    SLAuthorizationStateExpired,
};

/// sdk授权服务
@interface SLSDKAuthProvider : NSObject
@property (nonatomic, assign, readonly) SLAuthorizationState authState;

+ (instancetype)shared;


/// 同步授权服务信息
- (void)syncAuthInfo;


/// 重置缓存授权状态，不该写本地文件
- (void)resetCacheAuthState;


/// 请求授权
- (void)registerWithAppId:(NSString*)appId appSecret:(NSString*)appSecret;
@end

NS_ASSUME_NONNULL_END
