//
//  SLFaceLandmark.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLFaceLandmark.h"
#import "SLSDKAuthProvider.h"

void SLFaceLandmarkRegister(NSString *appId, NSString *appSecret) {
    [[SLSDKAuthProvider shared]registerWithAppId:appId appSecret:appSecret];
}

@implementation SLFaceLandmark
+ (void)registerWithAppId:(NSString*)appId appSecret:(NSString*)appSecret {
    [[SLSDKAuthProvider shared]registerWithAppId:appId appSecret:appSecret];
}
@end
