//
//  SLMouthFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLMouthFeatureAnalyzer.h"
#import "SLPointsUtils.h"
#import "SLArithmeticUtils.h"


FOUNDATION_STATIC_INLINE NSArray *p_MouthPointsIndexes(void) {
    return @[@(93), @(86), @(90), @(84), @(98), @(87), @(102), @(101)];
}

#pragma mark - SLMouthFeature

@implementation SLMouthFeature

- (NSDictionary*)JSONObject {
    
    NSMutableDictionary *JSONDict = [[NSMutableDictionary alloc]init];
    [JSONDict setObject:@(self.angulusOris) forKey:@"angulusOris"];
    [JSONDict setObject:@(self.lipThickness) forKey:@"lipThickness"];
    [JSONDict setObject:@(self.mouthHeight) forKey:@"mouthHeight"];
    [JSONDict setObject:@(self.mouthWidth) forKey:@"mouthWidth"];
    NSString *mouthType = (self.mouthType.length > 0 ? self.mouthType : @"");
    [JSONDict setObject:mouthType forKey:@"mouthType"];
    return [NSDictionary dictionaryWithDictionary:JSONDict];
}

- (BOOL)isEqualToFeature:(id)object {
    
    if (!object || ![object isKindOfClass:[SLMouthFeature class]]) {
        return NO;
    }
    SLMouthFeature *feature = (SLMouthFeature*)object;
    return (self.angulusOris == feature.angulusOris &&
            self.lipThickness == feature.lipThickness &&
            self.mouthHeight == feature.mouthHeight &&
            self.mouthWidth == feature.mouthWidth &&
            [self.mouthType isEqualToString:feature.mouthType]);
}
@end

#pragma mark - SLMouthFeatureAnalyzer

@implementation SLMouthFeatureAnalyzer

+ (SLMouthFeature*)analysisInLandmarks:(nullable NSArray *)landmarks {
    
    if (!landmarks || landmarks.count <= 0) {
        return nil;
    }
    
    NSArray *points = SLGetPoints(landmarks, p_MouthPointsIndexes());
    if (!points || points.count != p_MouthPointsIndexes().count) {
        return nil;
    }
    
    SLMouthFeature *feature = [[SLMouthFeature alloc]init];
    
    // 点 93, 86, 90, 84, 98, 87, 102, 101
    CGPoint point93 = [points[0] CGPointValue];
    CGPoint point86 = [points[1] CGPointValue];
    CGPoint point90 = [points[2] CGPointValue];
    CGPoint point84 = [points[3] CGPointValue];
    CGPoint point98 = [points[4] CGPointValue];
    CGPoint point87 = [points[5] CGPointValue];
    CGPoint point102 = [points[6] CGPointValue];
    CGPoint point101 = [points[7] CGPointValue];
    
    // 嘴唇高度(mouthHeight)
    feature.mouthHeight = SLGetPointYSpace(point93, point86);
    
    // 嘴唇宽度(mouthWidth)
    feature.mouthWidth = SLGetPointXSpace(point90, point84);
    
    // 嘴唇厚度(lipThickness)
    // 上唇 下唇
    float upperLipHeight = SLGetPointYSpace(point98, point87);
    float underLipHeight = SLGetPointYSpace(point101, point102);
    feature.lipThickness = (upperLipHeight + underLipHeight) / 2.0;
    
    // 嘴角弯曲度(angulusOris)
    CGLine line1 = CGlineMake(point101, point90);
    CGLine line2 = CGlineMake(point90, point101);
    float degree = SLGetDegreeBetweenTwoLines(line1, line2);
    feature.angulusOris = degree;
    
    // 唇型(mouthType)
    if (degree > 100) {
        feature.mouthType = @"微笑唇";
    }
    else if (degree > 9) {
        feature.mouthType = @"厚唇";
    }
    else {
        feature.mouthType = @"标准唇";
    }
    return feature;
}
@end
