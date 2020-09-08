//
//  SLFaceLandmarks.m
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLFaceDetectionResult.h"

@implementation SLFace

@end

@implementation SLFaceDetectionResult
- (NSString*)description {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(self.faceNum) forKey:@"faceNum"];
    
    NSMutableArray *facesArray = [NSMutableArray array];
    for (SLFace *face in self.faces) {
        NSMutableDictionary *faceDict = [NSMutableDictionary dictionary];
        [faceDict setObject:NSStringFromCGRect(face.faceRect) forKey:@"faceRect"];
        
        NSMutableArray *landmarks = [NSMutableArray array];
        for (NSValue *value in face.landmarks) {
            CGPoint point = [value CGPointValue];
            [landmarks addObject:NSStringFromCGPoint(point)];
        }
        [faceDict setObject:landmarks forKey:@"landmarks"];
        [facesArray addObject:faceDict];
    }
    [dict setObject:facesArray forKey:@"faces"];
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (!JSONData) {
        return error.description;
    }
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return JSONString;
}
@end
