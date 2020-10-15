//
//  SLSDKAuthProvider.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/1.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLSDKAuthProvider.h"
#import "SLRSAProvider.h"
#import "SLSDKAuthAPI.h"
#import <UIKit/UIKit.h>
#import "NSDictionary+SLSDKAuth.h"
#import "SLSDKJSONFile.h"
#import <AdSupport/AdSupport.h>

@interface SLSDKAuthProvider ()
@property (nonatomic,   copy) NSString *appId;
@property (nonatomic,   copy) NSString *appSecret;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end


static NSString *KRSAPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2/36nQTAJKRF6HEcIg7T7qrgTaYLdO1JrYUB8F3X83a+f5/Epcsww/VYvId29lgGyy7hawy294LIYxicYwyQaq8lI8ojhGF0D4u81gp+eW9pe69rvLKUVBq4r4hkxVqNgn4avZScyqxlELZdWwgzZONAcsgjMl5UNA75EAg8nIQIDAQAB";

@implementation SLSDKAuthProvider
@synthesize authState = _authState;

- (void)resetAuthState {
    
}

#pragma mark - init

+ (instancetype)shared
{
    static SLSDKAuthProvider *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc]init];
        // 注册后台切入前台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)appDidBecomeActive {
    [self syncAuthInfoFromServer];
}

- (void)syncAuthInfo {
    [self syncAuthInfoFromServer];
}

- (void)resetCacheAuthState {
    _authState = SLAuthorizationStateUnknown;
    [self syncAuthInfoFromServer];
}

#pragma mark - auth

- (void)registerWithAppId:(NSString *)appId appSecret:(NSString *)appSecret {
    NSAssert(appId != nil && appSecret != nil, @"请输入有效的授权AppId和AppSecret");
    _appId = appId.copy;
    _appSecret = appSecret.copy;
    // 读取本地授权状态
    [self readAuthState];
    // 请求服务器最新授权信息
    [self syncAuthInfoFromServer];
}

- (void)readAuthState {
    [_lock lock];
    // 从钥匙链读取授权信息
    NSError *error;
    NSDictionary *JSONObject = [SLSDKJSONFile readJSON:&error];
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) {
        SSALOG(@"---授权文件读取失败--%@",error);
        _authState = SLAuthorizationStateAuthDataError;
        [_lock unlock];
        return;
    }
    // 如果本地授权文件包含授权错误信息,则读取错误状态
    if ([JSONObject.allKeys containsObject:@"msg"]) {
        NSInteger code = [JSONObject[@"code"]unsignedIntegerValue];
        if (code == 150000077) {
            _authState = SLAuthorizationStateExpired;
        }
        else {
            _authState = SLAuthorizationStateUnAuthorized;
        }
        [_lock unlock];
        return;
    }
    if ([self RSAAuthVerifyFromJSON:JSONObject]) {
        _authState = [self authStateFromJSON:JSONObject];
    }
    else {
        _authState = SLAuthorizationStateRSAVerifyFailed;
    }
    [_lock unlock];
}

#pragma mark - auth state

- (SLAuthorizationState)authState {
    if (_authState == SLAuthorizationStateAuthorized) {
        return _authState;
    }
    [self readAuthState];
    return _authState;
}

#pragma mark - sync auth info

- (void)syncAuthInfoFromServer {
    if (self.dataTask && self.dataTask.state != NSURLSessionTaskStateCompleted) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.dataTask = [SLSDKAuthAPI authWithAppId:self.appId appSecret:self.appSecret result:^(SLSDKAuthContext *context ,id responseObject, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            SSALOG(@"---error--%@",error);
            [strongSelf handleErrorResponse:error];
            return;
        }
        SSALOG(@"---responseObject---%@",responseObject);
        [strongSelf handleResponseJSON:responseObject];
    }];
}

- (void)handleErrorResponse:(NSError*)error {
    if (error.code == 150000077 || error.code == 150000076) {
        [_lock lock];
        if (error.code == 150000077) {
            _authState = SLAuthorizationStateExpired;
        }
        else if (error.code == 150000076) {
            _authState = SLAuthorizationStateUnAuthorized;
        }
        // SDK授权过期或者未授权,将数据写入到本地保存
        NSDictionary *JSON = @{@"code":@(error.code), @"msg":error.localizedDescription};
        NSError *JSONError;
        BOOL ret = [SLSDKJSONFile writeJSON:JSON error:&JSONError];
        if (!ret) {
            NSLog(@"--授权信息写入文件错误--%@",JSONError);
        }
        [_lock unlock];
    }
}

#pragma mark - response

- (void)handleResponseJSON:(NSDictionary*)JSONObject {
    [self.lock lock];
    // 服务器时间校准
    NSNumber *server_time = SSANumberForKeyInDict(JSONObject, @"server_time");
    if (server_time && server_time.longLongValue > 10000) {
        NSTimeInterval timeInteval = (server_time.longLongValue / 1000.0) - [NSDate.date timeIntervalSince1970];
        SSASaveTimeDifferenceBetweenServerAndLocal(timeInteval);
    }
    // 将授权信息写入本地
    NSError *error;
    BOOL ret = [SLSDKJSONFile writeJSON:JSONObject error:&error];
    if (!ret) {
        NSLog(@"--授权信息写入文件错误--%@",error);
    }
    BOOL authResult = [self RSAAuthVerifyFromJSON:JSONObject];
    if (authResult) {
        _authState = [self authStateFromJSON:JSONObject];
    }
    else {
        _authState = SLAuthorizationStateRSAVerifyFailed;
    }
    [self.lock unlock];
}

#pragma mark - unsignedText

- (NSString*)unsignedTextFromResponseJSON:(NSDictionary*)JSONObject{
    if (!JSONObject) return nil;
    
    NSNumber *server_time = SSASafeNumberForKeyInDict(JSONObject, @"server_time");
    NSNumber *auth_end_time = SSASafeNumberForKeyInDict(JSONObject, @"auth_end_time");
    NSNumber *auth_start_time = SSASafeNumberForKeyInDict(JSONObject, @"auth_start_time");
    
    // 生成unsign字符串
    NSMutableString *unsignedText = [NSMutableString string];
    [unsignedText appendFormat:@"%@",self.appId];
    [unsignedText appendFormat:@"%@",self.appSecret];
    [unsignedText appendFormat:@"%@",@(4)];
//    [unsignedText appendFormat:@"%@",@"--无用的字符--"];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    idfa = [idfa stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [unsignedText appendFormat:@"%@",idfa];
    [unsignedText appendFormat:@"%@",server_time];
    [unsignedText appendFormat:@"%@",auth_start_time];
    [unsignedText appendFormat:@"%@",auth_end_time];
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [unsignedText appendFormat:@"%@",bundleId];
    SSALOG(@"--unsignedText--%@",unsignedText);
    return unsignedText;
}

#pragma mark - auth state

- (SLAuthorizationState)authStateFromJSON:(NSDictionary*)JSONObject {
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) return NO;
    // 获取授权结束时间
    NSNumber *auth_end_time = SSASafeNumberForKeyInDict(JSONObject, @"auth_end_time");
    NSNumber *auth_start_time = SSASafeNumberForKeyInDict(JSONObject, @"auth_start_time");
    NSTimeInterval timeDifference = SSAGetServerAndLocalTimeDifference();
    NSTimeInterval localTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fixedTimeInterval = (NSTimeInterval)((localTime + timeDifference) * 1000);
    if (fixedTimeInterval < auth_start_time.doubleValue) {
        return SLAuthorizationStateUnAuthorized;
    }
    if (fixedTimeInterval <= auth_end_time.doubleValue) {
        return SLAuthorizationStateAuthorized;
    }
    if (fixedTimeInterval > auth_end_time.doubleValue) {
        return SLAuthorizationStateExpired;
    }
    return SLAuthorizationStateUnknown;
}

#pragma mark - rsa verify

- (BOOL)RSAAuthVerifyFromJSON:(NSDictionary*)JSONObject {
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) return NO;
//    NSString *public_key = SSAStringForKeyInDict(JSONObject, @"public_key");
//    if (!public_key) return NO;
    NSString *sign = SSAStringForKeyInDict(JSONObject, @"sign");
    if (!sign) return NO;
    NSString *unsignedText = [self unsignedTextFromResponseJSON:JSONObject];
    NSString *pemKey = SLRSAPEMKeyFromBase64(KRSAPublicKey, YES);
    int result = SLRSASha1VerifyWithPublicKey(pemKey, unsignedText, sign);
    if (result == 1) {
        SSALOG(@"---RSA签名认证成功--");
        return YES;
    }
    return NO;
}
@end
