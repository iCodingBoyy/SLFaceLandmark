//
//  SLSDKJSONFile.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLSDKJSONFile.h"
#import "SLSDKAuthDefine.h"

@implementation SLSDKJSONFile

#pragma mark - JSON File

+ (NSString*)defaultJSONFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *JSONFilePath = [path stringByAppendingPathComponent:@"SLAuthJSON"];
    return JSONFilePath;
}

+ (NSDictionary*)readJSON:(NSError**)error {
    NSString *JSONFile = [self defaultJSONFile];
    return [self readJSON:JSONFile error:error];
}

+ (BOOL)writeJSON:(id)JSONObject error:(NSError**)error {
    NSString *JSONFile = [self defaultJSONFile];
    return [self writeJSON:JSONObject toFile:JSONFile error:error];
}

#pragma mark - JSON Read/Write

+ (NSDictionary*)readJSON:(NSString*)JSONFile error:(NSError**)error {
    if (!JSONFile) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"JSONFile不存在"};
        *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKJSONErrorInvalidJSONFilePath userInfo:userInfo];
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:JSONFile]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"JSONFile不存在"};
        *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKJSONErrorInvalidJSONFilePath userInfo:userInfo];
        return nil;
    }
    NSData *data = [[NSData alloc]initWithContentsOfFile:JSONFile];
    NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:error];
    if (!JSONObject) {
        NSLog(@"---读取授权文件错误---%@",*error);
    }
    return JSONObject;
}

+ (BOOL)writeJSON:(id)JSONObject toFile:(NSString*)JSONFile error:(NSError**)error {
    if (!JSONObject) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"JSONObject不存在"};
        *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKJSONErrorInvalidJSONObject userInfo:userInfo];
        return NO;
    }
    if (!JSONFile) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"JSONFile不存在"};
        *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKJSONErrorInvalidJSONFilePath userInfo:userInfo];
        return NO;
    }
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:error];
    if (!JSONData) {
        NSLog(@"--JSON序列化错误--%@",*error);
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:JSONFile]) {
       BOOL ret = [fileManager createFileAtPath:JSONFile contents:JSONData attributes:nil];
        if (!ret) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"创建JSON文件失败"};
            *error = [NSError errorWithDomain:SLSDKAuthDomain code:SLSDKJSONErrorCreateJSONFileError userInfo:userInfo];
            return NO;
        }
    }
    BOOL ret = [JSONData writeToFile:JSONFile options:NSDataWritingAtomic error:error];
    if (!ret) {
        NSLog(@"--JSONData写入错误--%@",*error);
    }
    return ret;
}
@end
