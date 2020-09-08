//
//  SLSDKAuthAPI.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSDKAuthDefine.h"


typedef void(^SLSDKAuthResultHandler)(SLSDKAuthContext *context, id responseObject, NSError *error);

@interface SLSDKAuthAPI : NSObject
+ (NSURLSessionDataTask*)authWithAppId:(NSString*)appId appSecret:(NSString*)appSecret result:(SLSDKAuthResultHandler)retHandler;
+ (NSURLSessionDataTask*)authWithParameter:(SLSDKAuthContext*)context result:(SLSDKAuthResultHandler)retHandler;
@end


FOUNDATION_EXPORT NSString* SSANSStringFromQueryParameters(NSDictionary* queryParameters);
FOUNDATION_EXPORT NSURL* SSANSURLByAppendingQueryParameters(NSURL* URL, NSDictionary *queryParameters);
