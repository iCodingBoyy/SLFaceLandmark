//
//  SLSDKJSONFile.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/2.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SLSDKJSONErrorCode) {
    SLSDKJSONErrorUnknown = 0,
    SLSDKJSONErrorInvalidJSONFilePath,
    SLSDKJSONErrorInvalidJSONObject,
    SLSDKJSONErrorCreateJSONFileError,
};

@interface SLSDKJSONFile : NSObject
+ (NSDictionary*)readJSON:(NSString*)JSONFile error:(NSError**)error;
+ (BOOL)writeJSON:(id)JSONObject toFile:(NSString*)JSONFile error:(NSError**)error;

+ (NSString*)defaultJSONFile;
+ (NSDictionary*)readJSON:(NSError**)error;
+ (BOOL)writeJSON:(id)JSONObject error:(NSError**)error;
@end

