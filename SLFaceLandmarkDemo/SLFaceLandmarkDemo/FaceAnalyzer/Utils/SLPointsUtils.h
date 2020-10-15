//
//  SLPointsUtils.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>


/// 获取landmarks对应索引的坐标点
/// @param landmarks 人脸关键点
/// @param pointsIndexes 关键点索引数组
FOUNDATION_EXPORT NSArray<NSValue*>* SLGetPoints(NSArray *landmarks, NSArray *pointsIndexes);


/// 获取两个坐标的X间距
/// @param point1 point1
/// @param point2 point2
FOUNDATION_EXPORT CGFloat SLGetPointXSpace(CGPoint point1, CGPoint point2);


/// 获取两个坐标的Y间距
/// @param point1 point1
/// @param point2 point2
FOUNDATION_EXPORT CGFloat SLGetPointYSpace(CGPoint point1, CGPoint point2);
