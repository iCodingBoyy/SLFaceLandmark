//
//  SLFiveEyesAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLFiveEyesAnalyzer.h"
#import "SLPointsUtils.h"
#import "SLArithmeticUtils.h"

SLEyePart *SLEyePartInit(float leftEye, float eyeSpace, int eye);

#pragma mark - SLEyePart

@implementation SLEyePart

- (nonnull NSDictionary *)JSONObject {
    return nil;
}

- (BOOL)isEqualToFeature:(nonnull id)object {
    
    return NO;
}
@end

#pragma mark - SLFiveEyes

@implementation SLFiveEyes

- (nonnull NSDictionary *)JSONObject {
    return nil; 
}

- (BOOL)isEqualToFeature:(nonnull id)object {
    return NO;
}

@end




#pragma mark - SLFiveEyesAnalyzer

FOUNDATION_STATIC_INLINE NSArray *p_FiveEyesPointsIndexes(void) {
    return @[@(2), @(52), @(55), @(61), @(30)];
}
 
@implementation SLFiveEyesAnalyzer
+ (SLFiveEyes*)analysisInLandmarks:(nullable NSArray*)landmarks {
    
    if (!landmarks || landmarks.count <= 0) {
        return nil;
    }
    
    NSArray *points = SLGetPoints(landmarks, p_FiveEyesPointsIndexes());
    if (!points || points.count != p_FiveEyesPointsIndexes().count) {
        return nil;
    }
    
    SLFiveEyes *feature = [[SLFiveEyes alloc]init];
    // 点 2, 52, 55, 58, 61, 30
    CGPoint point2 = [points[0] CGPointValue];
    CGPoint point52 = [points[1] CGPointValue];
    CGPoint point55 = [points[2] CGPointValue];
    CGPoint point58 = [points[3] CGPointValue];
    CGPoint point61 = [points[4] CGPointValue];
    CGPoint point30 = [points[5] CGPointValue];
    
    // 左眼宽度(leftEye)
    {
        feature.leftEye = [[SLEyePart alloc]init];
        feature.leftEye.width = SLGetPointXSpace(point58, point61);
    }
    // 右眼外侧(oneEye)
    {
        float spaceX = SLGetPointXSpace(point2, point52);
        feature.oneEye = SLEyePartInit(feature.leftEye.width, spaceX, 1);
    }
    // 右眼宽度(rightEye)
    {
        float spaceX = SLGetPointXSpace(point55, point52);
        feature.rightEye = SLEyePartInit(feature.leftEye.width, spaceX, 0);
    }
    // 内眼角间距(threeEye)
    {
        float spaceX = SLGetPointXSpace(point58, point55);
        feature.threeEye = SLEyePartInit(feature.leftEye.width, spaceX, 2);
    }
    // 左眼外侧(fiveEye)
    {
        float spaceX = SLGetPointXSpace(point30, point61);
        feature.fiveEye = SLEyePartInit(feature.leftEye.width, spaceX, 3);
    }
    // 五眼比例:0.69:1.01:1.43:1:0.8
    feature.eyesRatio = [NSString stringWithFormat:@"%.2f:%.2f:%.2f:1:%.2f",feature.oneEye.ratio,feature.rightEye.ratio,feature.threeEye.ratio,feature.fiveEye.ratio];
    return feature;
}

@end



NSString *SLFiveEyesResult(int eye, float ratio) {
    NSString *result = nil;
    switch (eye) {
        //右眼外侧
        case 1:
            //左眼外侧
        case 3:
            if (ratio >= 0.84f) {
                result = @"偏宽";
            } else if (ratio <= 0.76f) {
                result = @"偏窄";
            } else {
                result = @"适中";
            }
            break;
        //内眼角间距
        case 2:
            if (ratio >= 1.24f) {
                result = @"偏宽";
            } else if (ratio <= 1.16f) {
                result = @"偏窄";
            } else {
                result = @"适中";
            }
            break;
        default:
            break;

    }
    return result;
}



SLEyePart *SLEyePartInit(float leftEye, float eyeSpace, int eye) {
    SLEyePart *part = [[SLEyePart alloc]init];
    part.width  = eyeSpace;
    if (leftEye > 0) {
        part.ratio = eyeSpace / leftEye;
    }
    if (eye > 0) {
        part.result = SLFiveEyesResult(eye, part.ratio);
    }
    return part;
}
