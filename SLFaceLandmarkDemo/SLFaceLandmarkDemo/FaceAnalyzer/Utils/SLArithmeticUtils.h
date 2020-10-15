//
//  SLArithmeticUtils.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface SLArithmeticUtils : NSObject
@end


typedef struct CG_BOXABLE  CGLine {
    CGPoint point1; ///< 直线第一个点坐标
    CGPoint point2; ///< 直线第二个点坐标
} CGLine;

FOUNDATION_EXPORT CGLine CGlineMake(CGPoint point1, CGPoint point2);

#pragma mark - 计算两点间距

/// 计算两点间的距离
/// @param point1 点 point1(x1,y1)
/// @param point2 点 point2(x2,y2)
FOUNDATION_EXPORT double SLDistanceBetween2Points(CGPoint point1, CGPoint point2);


#pragma mark - 计算点到直线的最短距离

/// 求点 point 到 line 的最短距离
/// @param point 直线外点坐标
/// @param line 直线
FOUNDATION_EXPORT double SLShortestDistanceFromPointToLine(CGPoint point, CGLine line);



#pragma mark - 计算两条直线的夹角


/// 计算两条直线的夹角弧度θ
/// @param line1 线1
/// @param line2 线2
FOUNDATION_EXPORT float SLGetDegreeBetweenTwoLines(CGLine line1, CGLine line2);


#pragma mark - 计算两条直线的交点

/// 求两条直线的交点坐标
/// @param line1 线1
/// @param line2 线2
/// @param crossPoint 夹角坐标
FOUNDATION_EXPORT BOOL SLFindCrossPointBetweenTwoLines(CGLine line1, CGLine line2, CGPoint *crossPoint);


NS_ASSUME_NONNULL_END
