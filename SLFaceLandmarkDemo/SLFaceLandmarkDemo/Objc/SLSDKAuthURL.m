//
//  SLSDKAuthURL.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLSDKAuthURL.h"

NSString *SLSDKAuthURLPath(void) {
    return @"/app/it/photo/chairdressing/auth/create";
}

#ifndef __DP__
 #define __DP__
#endif

NSString *SLSDKAuthURLDomain(void) {
#if defined(__DP__)
    return @"https://dp.clife.net";
#elif defined(__PRE__)
    return @"https://pre.open.api.clife.cn";
#elif defined(__ITEST__)
    return @"https://itest.clife.net";
#else
    return @"https://open.api.clife.cn";
#endif
}

@implementation SLSDKAuthURL

@end
