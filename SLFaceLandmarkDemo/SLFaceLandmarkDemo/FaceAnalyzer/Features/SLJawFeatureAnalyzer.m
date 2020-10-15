//
//  SLJawFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLJawFeatureAnalyzer.h"
#import "SLPointsUtils.h"
#import "SLArithmeticUtils.h"

FOUNDATION_STATIC_INLINE NSArray *p_JawFeatureIndexes(void) {
    return @[@(16),@(93),@(19),@(13)];
}

@implementation SLJawFeature

- (NSDictionary*)JSONObject {
    
    NSMutableDictionary *JSONDict = [[NSMutableDictionary alloc]init];
    [JSONDict setObject:@(self.jawAngle) forKey:@"jawAngle"];
    [JSONDict setObject:@(self.jawLength) forKey:@"jawLength"];
    [JSONDict setObject:@(self.jawWidth) forKey:@"jawWidth"];
    if (self.jawType.length > 0) {
        [JSONDict setObject:self.jawType forKey:@"jawType"];
    }
    else {
        [JSONDict setObject:@"" forKey:@"jawType"];
    }
    return [NSDictionary dictionaryWithDictionary:JSONDict];
}

- (BOOL)isEqualToFeature:(id)object {
    
    if (!object || ![object isKindOfClass:[SLJawFeature class]]) {
        return NO;
    }
    SLJawFeature *feature = (SLJawFeature*)object;
    return (self.jawAngle == feature.jawAngle &&
            self.jawWidth == feature.jawWidth &&
            self.jawLength == feature.jawLength &&
            [self.jawType isEqualToString:feature.jawType]);
}

@end

@implementation SLJawFeatureAnalyzer
+ (SLJawFeature*)analysisInLandmarks:(NSArray*)landmarks {
    
    if (!landmarks || landmarks.count <= 0) {
        return nil;
    }
    NSArray *points = SLGetPoints(landmarks, p_JawFeatureIndexes());
    if (!points || points.count != p_JawFeatureIndexes().count) {
        return nil;
    }
    SLJawFeature *feature = [[SLJawFeature alloc]init];
    
    CGPoint point16 = [points[0] CGPointValue];
    CGPoint point93 = [points[1] CGPointValue];
    CGPoint point19 = [points[2] CGPointValue];
    CGPoint point13 = [points[3] CGPointValue];
    
    // 下巴长度(jawLength)
    feature.jawLength = SLGetPointYSpace(point16, point93);
    
    //下巴宽度(jawWidth)
    feature.jawWidth = SLGetPointXSpace(point19, point13);
    
    //下巴角度(jawAngle)
    CGLine line1 = CGlineMake(point13, point19);
    CGLine line2 = CGlineMake(point13, point16);
    feature.jawAngle = SLGetDegreeBetweenTwoLines(line1, line2);

    
    if (feature.jawAngle >= 155) {
        feature.jawType = @"方下巴";
    }
    else if (feature.jawAngle <= 145) {
        feature.jawType = @"尖下巴";
    }
    else {
        feature.jawType = @"圆下巴";
    }
    return feature;
}
@end
