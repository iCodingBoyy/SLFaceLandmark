//
//  SLPointsUtils.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLPointsUtils.h"

NSArray<NSValue*>* SLGetPoints(NSArray *landmarks, NSArray *pointsIndexes) {
    if ( !landmarks || landmarks.count <= 0) {
        return nil;
    }
    if ( !pointsIndexes || pointsIndexes.count <= 0) {
        return nil;
    }
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    for (int index = 0; index < pointsIndexes.count; index++) {
        NSNumber *indexValue = pointsIndexes[index];
        if (indexValue.intValue < landmarks.count) {
            NSValue *value = landmarks[indexValue.intValue];
            [tmpArray addObject:value];
        }
    }
    return [NSArray arrayWithArray:tmpArray];
}

CGFloat SLGetPointXSpace(CGPoint point1, CGPoint point2) {
    CGFloat value = 0;
    value = fabs(point1.x - point2.x);
    return value;
}

CGFloat SLGetPointYSpace(CGPoint point1, CGPoint point2) {
    CGFloat value = 0;
    value = fabs(point1.y - point2.y);
    return value;
}
