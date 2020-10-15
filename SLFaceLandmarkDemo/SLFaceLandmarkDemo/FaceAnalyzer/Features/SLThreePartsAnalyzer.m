//
//  SLThreePartsAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLThreePartsAnalyzer.h"
#import "SLPointsUtils.h"
#import "SLArithmeticUtils.h"

#pragma mark - SLThreePart

@implementation SLThreePart

@end

#pragma mark - SLThreeParts

@implementation SLThreeParts

@end

FOUNDATION_STATIC_INLINE NSArray *p_ThreePartsPointsIndexes(void) {
    return @[@(115), @(67), @(68), @(49), @(16)];
}

#pragma mark - SLThreePartsAnalyzer

@implementation SLThreePartsAnalyzer

+ (SLThreeParts*)analysisInLandmarks:(nullable NSArray*)landmarks {
    if (!landmarks || landmarks.count <= 0) {
        return nil;
    }
    NSArray *points = SLGetPoints(landmarks, p_ThreePartsPointsIndexes());
    if (!points || points.count != p_ThreePartsPointsIndexes().count) {
        return nil;
    }
    
    SLThreeParts *feature = [[SLThreeParts alloc]init];
    /// 115, 67, 68, 49, 16
    CGPoint point115 = [points[0] CGPointValue];
    CGPoint point67 = [points[1] CGPointValue];
    CGPoint point68 = [points[2] CGPointValue];
    CGPoint point49 = [points[3] CGPointValue];
    CGPoint point16 = [points[4] CGPointValue];
    
    // 脸长(faceLength)
    feature.faceLength = SLDistanceBetween2Points(point16, point115);
    // 上庭(partOne)
    {
        CGLine line = CGlineMake(point67, point68);
        float distance = SLShortestDistanceFromPointToLine(point115, line);
        feature.partOne = [self partWithFaceLength:feature.faceLength distance:distance part:1];
    }
    
    // 中庭(partTwo)
    {
        CGLine line = CGlineMake(point67, point68);
        float distance = SLShortestDistanceFromPointToLine(point49, line);
        feature.partTwo = [self partWithFaceLength:feature.faceLength distance:distance part:2];
    }
    
    // 下庭(partThree)
    {
        float distance = SLDistanceBetween2Points(point16, point49);
        feature.partThree = [self partWithFaceLength:feature.faceLength distance:distance part:3];
    }
    feature.partsRatio = [NSString stringWithFormat:@"%.2f:%.2f:%.2f",feature.partOne.ratio,feature.partTwo.ratio,feature.partThree.ratio];
    return feature;
}

+ (SLThreePart*)partWithFaceLength:(float)faceLength distance:(float)distance part:(int)part {
    SLThreePart *partObj = [[SLThreePart alloc]init];
    partObj.length = distance;
    if (faceLength > 0) {
        partObj.ratio =  (distance / faceLength);
    }
    partObj.result = [self getThreePartsResult:part radio:partObj.ratio];
    return partObj;
}

+ (NSString*)getThreePartsResult:(int)part radio:(float)ratio {
    NSString *result = nil;
    switch (part) {
        //上庭
        case 1:
            if (ratio >= 0.35f) {
                result = @"上庭偏长";
            }
            else if (ratio <= 0.31f) {
                result = @"上庭偏短";
            }
            else {
                result = @"上庭标准";
            }
            break;
        //中庭
        case 2:
            if (ratio >= 0.35f) {
                result = @"中庭偏长";
            }
            else if (ratio <= 0.31f) {
                result = @"中庭偏短";
            }
            else {
                result = @"中庭标准";
            }
            break;
        //下庭
        case 3:
            if (ratio >= 0.35f) {
                result = @"下庭偏长";
            }
            else if (ratio <= 0.31f) {
                result = @"下庭偏短";
            }
            else {
                result = @"下庭标准";
            }
            break;
            break;
        default:
            break;

    }
    return result;
}

@end
