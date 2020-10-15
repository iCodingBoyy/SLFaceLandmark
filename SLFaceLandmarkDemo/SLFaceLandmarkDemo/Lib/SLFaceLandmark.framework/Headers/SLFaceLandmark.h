//
//  SLFaceLandmark.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

/// SDK 授权,可前往开放平台注册
/// @warning 使用前需要先注册授权，否则将无法正常使用
FOUNDATION_EXPORT void SLFaceLandmarkRegister(NSString *appId, NSString *appSecret);

@interface SLFaceLandmark : NSObject
+ (void)registerWithAppId:(NSString*)appId appSecret:(NSString*)appSecret;
@end
