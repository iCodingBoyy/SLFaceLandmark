//
//  SLSDKAuthAPI.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLSDKAuthAPI.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import "SLSDKAuthUtils.h"
#import "NSDictionary+SLSDKAuth.h"
#import "SLSDKAuthURL.h"

@implementation SLSDKAuthAPI

+ (NSURLSessionDataTask*)authWithAppId:(NSString*)appId appSecret:(NSString*)appSecret result:(SLSDKAuthResultHandler)retHandler {
    if (appId.length <= 0 || appSecret.length <= 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"请输入有效的AppId和AppSecret"};
        NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKAuthErrorInvalidParamter userInfo:userInfo];
        if (retHandler) retHandler(nil , nil, error);
        return nil;
    }
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    idfa = [idfa stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceType = [SLSDKAuthUtils deviceType];
    
    SLSDKAuthMutableContext *context = [[SLSDKAuthMutableContext alloc]init];
    [context SSASafeSetObject:@(4)       forKey:SLSDKAuthContextAppTypeKey];
    [context SSASafeSetObject:appId      forKey:SLSDKAuthContextAppIdKey];
    [context SSASafeSetObject:idfa       forKey:SLSDKAuthContextUUIDKey];
    [context SSASafeSetObject:osVersion  forKey:SLSDKAuthContextOsVersionKey];
    [context SSASafeSetObject:deviceType forKey:SLSDKAuthContextPhoneTypeKey];
    [context SSASafeSetObject:@"1.0.0"   forKey:SLSDKAuthContextSDKVersionKey];
    [context SSASafeSetObject:@""   forKey:SLSDKAuthContextExtJSONKey];
    
    SSALOG(@"---context---%@",context);
    return [self authWithParameter:context result:retHandler];
}

+ (NSURLSessionDataTask*)authWithParameter:(SLSDKAuthContext*)context result:(SLSDKAuthResultHandler)retHandler {
    if (!context) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"服务器返回错误的JSON数据"};
        NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKAuthErrorInvalidParamter userInfo:userInfo];
        if (retHandler) retHandler(context , nil, error);
        return nil;
    }
    
    NSString *urlString = [SLSDKAuthURLDomain() stringByAppendingString:SLSDKAuthURLPath()];
    NSURL *url = [NSURL URLWithString:urlString];
//    url = SSANSURLByAppendingQueryParameters(url, context);
    SSALOG(@"---请求url---%@",url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *postString = SSANSStringFromQueryParameters(context);
    SSALOG(@"---postString---%@",postString);
    NSData *postData = [SSANSStringFromQueryParameters(context) dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = postData;
    request.timeoutInterval = 30;
    request.HTTPMethod = @"POST";
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (retHandler) retHandler(context , nil, error);
            return;
        }
        // JSON数据序列化
        NSError *JSONError;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&JSONError];
        if (JSONError) {
            if (retHandler) retHandler(context , nil, JSONError);
            return;
        }
        SSALOG(@"---JSONObject---%@",JSONObject);
        // 校验JSON格式
        if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"服务器返回错误的JSON数据"};
            NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKAuthErrorInvalidRspDict userInfo:userInfo];
            if (retHandler) retHandler(context , nil, error);
            return;
        }
        // 校验JSON Code码
        NSDictionary *JSONDict = (NSDictionary*)JSONObject;
        if (!JSONDict || ![JSONDict.allKeys containsObject:@"code"]) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"服务器返回错误的JSON数据"};
            NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKAuthErrorInvalidRspKeyValues userInfo:userInfo];
            if (retHandler) retHandler(context , nil, error);
            return;
        }
        // 判断Code码
        int code = [JSONDict[@"code"] intValue];
        if ( code != 0 ) {
            NSString *errorMessage = JSONDict[@"msg"];
            errorMessage = errorMessage ? errorMessage : @"未知错误";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorMessage};
            NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:code userInfo:userInfo];
            if (retHandler) retHandler(context , nil, error);
            return;
        }
        NSDictionary *JSONData = JSONDict[@"data"];
        if (JSONData.allKeys.count <= 0) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"服务器返回空Data数据"};
            NSError *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKAuthErrorEmptyDataInRspDict userInfo:userInfo];
            if (retHandler) retHandler(context , nil, error);
        }
        if (retHandler) retHandler(context , JSONData, nil);
    }];
    [dataTask resume];
    return dataTask;
}
@end


/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
*/
NSString* SSANSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        value = [value isKindOfClass:[NSString class]] ? [value stringByAddingPercentEncodingWithAllowedCharacters:characterSet] : value;
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:characterSet],
                          value];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
*/
NSURL* SSANSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
        [URL absoluteString],
        SSANSStringFromQueryParameters(queryParameters)
    ];
    return [NSURL URLWithString:URLString];
}
