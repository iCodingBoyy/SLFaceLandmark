//
//  SLGoldenTriangleAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLGoldenTriangleAnalyzer.h"
#import "SLPointsUtils.h"
#import "SLArithmeticUtils.h"


FOUNDATION_STATIC_INLINE NSArray *p_GoldenTrianglePointsIndexes(void) {
    return @[@(115), @(67), @(68), @(49), @(16)];
}


@implementation SLGoldenTriangleAnalyzer

+ (CGFloat)analysisInLandmarks:(nullable NSArray*)landmarks {
    
    if (!landmarks || landmarks.count <= 0) {
        return 0.0;
    }
    
    NSArray *points = SLGetPoints(landmarks, p_GoldenTrianglePointsIndexes());
    if (!points || points.count != p_GoldenTrianglePointsIndexes().count) {
        return 0.0;
    }
    
    // 点 77, 49, 74
    CGPoint point77 = [points[0] CGPointValue];
    CGPoint point49 = [points[1] CGPointValue];
    CGPoint point74 = [points[2] CGPointValue];
    
    CGLine line1 = CGlineMake(point77, point49);
    CGLine line2 = CGlineMake(point74, point49);
    float degree = SLGetDegreeBetweenTwoLines(line1, line2);
    return degree;
}
@end
