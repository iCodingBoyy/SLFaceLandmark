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

@implementation SLSDKAuthProvider
@synthesize authorized = _authorized;

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
//    NSLog(@"%@", NSStringFromSelector(_cmd));
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
        [_lock unlock];
        return;
    }
    BOOL ret = [self RSAAuthVerifyFromJSON:JSONObject];
    if (ret) {
        _authorized = [self authStateFromJSON:JSONObject];
    }
    else {
        _authorized = NO;
    }
    [_lock unlock];
}

#pragma mark - auth state

- (BOOL)isAuthorized {
    if (_authorized) {
        return _authorized;
    }
    // 读取本地授权状态
    [self readAuthState];
    return _authorized;
}

- (void)syncAuthInfoFromServer {
    if (self.dataTask && self.dataTask.state != NSURLSessionTaskStateCompleted) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.dataTask = [SLSDKAuthAPI authWithAppId:self.appId appSecret:self.appSecret result:^(SLSDKAuthContext *context ,id responseObject, NSError *error) {
        if (error) {
            SSALOG(@"---error--%@",error);
            return;
        }
        SSALOG(@"---responseObject---%@",responseObject);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleResponseJSON:responseObject];
    }];
}

- (void)handleResponseJSON:(NSDictionary*)JSONObject {
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) return;
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
        _authorized = [self authStateFromJSON:JSONObject];
    }
    else {
        _authorized = NO;
    }
    [self.lock unlock];
}


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
    idfa = [idfa stringByReplacingOccurrencesOfString:@"-" withString:@"-"];
    [unsignedText appendFormat:@"%@",idfa];
    [unsignedText appendFormat:@"%@",server_time];
    [unsignedText appendFormat:@"%@",auth_start_time];
    [unsignedText appendFormat:@"%@",auth_end_time];
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [unsignedText appendFormat:@"%@",bundleId];
    SSALOG(@"--unsignedText--%@",unsignedText);
    return unsignedText;
}


- (BOOL)authStateFromJSON:(NSDictionary*)JSONObject {
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) return NO;
    // 获取授权结束时间
    NSNumber *auth_end_time = SSASafeNumberForKeyInDict(JSONObject, @"auth_end_time");
    NSTimeInterval timeDifference = SSAGetServerAndLocalTimeDifference();
    NSTimeInterval localTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fixedTimeInterval = (NSTimeInterval)((localTime + timeDifference) * 1000);
    // 检查当前时间是否大于授权结束时间
    return (fixedTimeInterval < auth_end_time.doubleValue);
}


- (BOOL)RSAAuthVerifyFromJSON:(NSDictionary*)JSONObject {
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) return NO;
    NSString *public_key = SSAStringForKeyInDict(JSONObject, @"public_key");
    if (!public_key) return NO;
    NSString *sign = SSAStringForKeyInDict(JSONObject, @"sign");
    if (!sign) return NO;
    NSString *unsignedText = [self unsignedTextFromResponseJSON:JSONObject];
    NSString *pemKey = SLRSAPEMKeyFromBase64(public_key, YES);
    int result = SLRSASha1VerifyWithPublicKey(pemKey, unsignedText, sign);
    if (result == 1) {
        SSALOG(@"---RSA签名认证成功--");
        return YES;
    }
    return NO;
}
@end
