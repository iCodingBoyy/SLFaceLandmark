//
//  SLSDKAuthProvider.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/1.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// sdk授权服务
@interface SLSDKAuthProvider : NSObject
// 判断SDK是否授权
/// @discussion 优先从本地读取授权信息，在异步从服务器获取最新授权信息
@property (nonatomic, assign, getter=isAuthorized) BOOL authorized;
+ (instancetype)shared;
/// 请求授权
- (void)registerWithAppId:(NSString*)appId appSecret:(NSString*)appSecret;

@end

NS_ASSUME_NONNULL_END
