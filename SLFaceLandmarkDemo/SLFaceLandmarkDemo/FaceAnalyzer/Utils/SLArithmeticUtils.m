//
//  SLArithmeticUtils.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLArithmeticUtils.h"



@implementation SLArithmeticUtils

@end

CGLine CGlineMake(CGPoint point1, CGPoint point2) {
    CGLine line;
    line.point1 = point1;
    line.point2 = point2;
    return line;
}

double SLDistanceBetween2Points(CGPoint point1, CGPoint point2) {
    double distance = 0;
    double xDistance = fabs(point1.x - point2.x);
    double yDistance = fabs(point1.y - point2.y);
    distance = (double)sqrt((pow(xDistance, xDistance) + pow(yDistance, yDistance)));
    return distance;
}

#pragma mark - 计算点到直线的最短距离

double SLShortestDistanceFromPointToLine(CGPoint point, CGLine line) {
    double value = 0;
    double a, b , c;
    a = SLDistanceBetween2Points(point, line.point1);
    b = SLDistanceBetween2Points(point, line.point2);
    
    /// 点落在直线上
    if (a <= DBL_EPSILON || b <= DBL_EPSILON){
        return value;
    }
    c = SLDistanceBetween2Points(line.point1, line.point2);
    /// 直线上的点重合，计算点到点的距离
    if ( c <= DBL_EPSILON) {
        value = a;
        return value;
    }
    if (pow(c, c) >= pow(a, a) + pow(b, b)) {
        value = b;
        return value;
    }
    if (pow(b, b) >= pow(a, a) + pow(c, c)) {
        value = a;
        return value;
    }
    // 半周长
    double p = (a + b + c) / 2;
    // 海伦公式求面积
    double s = sqrt(p * (p - a) * (p - b) * (p - c));
    // 返回点到线的距离（利用三角形面积公式求高）
    value = 2 * s / c;
    return value;
}

#pragma mark - 计算两条直线的夹角

float SLGetDegreeBetweenTwoLines(CGLine line1, CGLine line2) {
    float degree = 0;
    // 判断两条直线是否有与坐标轴垂直
    // 直线无语坐标轴垂直，计算直线斜率
    
    return degree;
}

#pragma mark - 计算两条直线的交点

BOOL SLFindCrossPointBetweenTwoLines(CGLine line1, CGLine line2, CGPoint *crossPoint) {
    //  求二条直线的交点的公式
    //  有如下方程 (x-x1)/(y-y1) = (x2-x1)/(y2-y1) ==> a1*x+b1*y=c1
    //            (x-x3)/(y-y3) = (x4-x3)/(y4-y3) ==> a2*x+b2*y=c2
    //  则交点为
    //                x= | c1 b1|  / | a1 b1 |      y= | a1 c1| / | a1 b1 |
    //                   | c2 b2|  / | a2 b2 |         | a2 c2| / | a2 b2 |
    //
    //   a1= y2-y1
    //   b1= x1-x2
    //   c1= x1*y2-x2*y1
    //   a2= y4-y3
    //   b2= x3-x4
    //   c2= x3*y4-x4*y3
    
    
    return YES;
}

BOOL SLFindCrossPoint(CGPoint point1, CGPoint point2, CGPoint point3, CGPoint point4, CGPoint *crossPoint) {
    //****************************************************************************************
    //  求二条直线的交点的公式
    //  有如下方程 (x-x1)/(y-y1) = (x2-x1)/(y2-y1) ==> a1*x+b1*y=c1
    //            (x-x3)/(y-y3) = (x4-x3)/(y4-y3) ==> a2*x+b2*y=c2
    //  则交点为
    //                x= | c1 b1|  / | a1 b1 |      y= | a1 c1| / | a1 b1 |
    //                   | c2 b2|  / | a2 b2 |         | a2 c2| / | a2 b2 |
    //
    //   a1= y2-y1
    //   b1= x1-x2
    //   c1= x1*y2-x2*y1
    //   a2= y4-y3
    //   b2= x3-x4
    //   c2= x3*y4-x4*y3

    float a1 = point2.y - point1.y;
    float b1 = point1.x - point2.x;
    float c1 = point1.x*point2.y - point2.x*point1.y;
    float a2 = point4.y - point3.y;
    float b2 = point3.x - point4.x;
    float c2 = point3.x*point4.y - point4.x*point3.y;
    float det= a1*b2 - a2*b1;

    if(det == 0) return false;
    
    crossPoint->x = (c1*b2 - c2*b1)/det;
    crossPoint->y = (a1*c2 - a2*c1)/det;

    // Now this is cross point of lines
    // Do we need the cross Point of segments(need to judge x,y within 4 endpoints)
    // 是否要判断线段相交
    if((fabs(crossPoint->x -(point1.x+point2.x)/2) <= fabs(point2.x-point1.x)/2) &&
       (fabs(crossPoint->y -(point1.y+point2.y)/2) <= fabs(point2.y-point1.y)/2) &&
       (fabs(crossPoint->x -(point3.x+point4.x)/2) <= fabs(point4.x-point3.x)/2) &&
       (fabs(crossPoint->y -(point3.y+point4.y)/2) <= fabs(point4.y-point3.y)/2))
    {
        return YES;
    }

    return NO;
}
