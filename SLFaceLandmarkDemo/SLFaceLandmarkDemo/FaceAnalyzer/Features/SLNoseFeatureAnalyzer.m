//
//  SLNoseFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLNoseFeatureAnalyzer.h"
#import "SLPointsUtils.h"


FOUNDATION_STATIC_INLINE NSArray *p_NosePointsIndexes(void) {
    return @[@(83), @(82), @(49), @(43), @(87), @(87), @(55)];
};

CGFloat p_GetNoseRadio(CGFloat noseWidth, CGFloat innerEyeWidth);
NSString *p_GetNoseType(CGFloat radio);

#pragma mark - SLNoseFeature

@implementation SLNoseFeature
- (NSDictionary*)JSONObject {
    NSMutableDictionary *JSONDict = [[NSMutableDictionary alloc]init];
    [JSONDict setObject:@(self.noseWidth) forKey:@"noseWidth"];
    [JSONDict setObject:@(self.noseHeight) forKey:@"noseHeight"];
    [JSONDict setObject:@(self.philtrumWidth) forKey:@"philtrumWidth"];
    NSString *noseType = (self.noseType.length > 0 ? self.noseType : @"");
    [JSONDict setObject:noseType forKey:@"noseType"];
    return [NSDictionary dictionaryWithDictionary:JSONDict];
}

- (BOOL)isEqualToFeature:(id)object {
    if (!object || ![object isKindOfClass:[SLNoseFeature class]]) {
        return NO;
    }
    SLNoseFeature *feature = (SLNoseFeature*)object;
    return (self.noseWidth == feature.noseWidth &&
            self.noseHeight == feature.noseHeight &&
            self.philtrumWidth == feature.philtrumWidth &&
            [self.noseType isEqualToString:feature.noseType]);
}
@end

#pragma mark - SLNoseFeatureAnalyzer

@implementation SLNoseFeatureAnalyzer

+ (SLNoseFeature*)analysisInLandmarks:(NSArray*)landmarks {
    
    if (!landmarks || landmarks.count <= 0) {
        return nil;
    }
    
    NSArray *points = SLGetPoints(landmarks, p_NosePointsIndexes());
    if (!points || points.count != p_NosePointsIndexes().count) {
        return nil;
    }
    
    //点83, 82, 49, 43, 87, 58, 55
    SLNoseFeature *noseFeature = [[SLNoseFeature alloc]init];
    
    //鼻翼宽度(noseWidth)
    CGPoint point83 = [points[0] CGPointValue];
    CGPoint point82 = [points[1] CGPointValue];
    noseFeature.noseWidth = SLGetPointXSpace(point83, point82);
    
    //鼻子长度(noseHeight)
    CGPoint point49 = [points[2] CGPointValue];
    CGPoint point43 = [points[3] CGPointValue];
    noseFeature.noseHeight = SLGetPointYSpace(point49, point43);
    
    //人中长度(philtrumWidth)
    CGPoint point87 = [points[4] CGPointValue];
    noseFeature.philtrumWidth = SLGetPointYSpace(point87, point49);
    
    // 内眼角间距
    CGPoint point58 = [points[5] CGPointValue];
    CGPoint point55 = [points[6] CGPointValue];
    CGFloat innerEyeWidth = SLGetPointXSpace(point58, point55);
    
    //鼻型(noseType)
    CGFloat radio = p_GetNoseRadio(noseFeature.noseWidth, innerEyeWidth);
    noseFeature.noseType = p_GetNoseType(radio);
    return noseFeature;
}

@end



#pragma mark - Private


CGFloat p_GetNoseRadio(CGFloat noseWidth, CGFloat innerEyeWidth) {
    CGFloat radio = 0;
    if (innerEyeWidth > DBL_EPSILON) {
        radio = noseWidth / innerEyeWidth;
    }
    return radio;
}

static NSString *RESULT_NOSE_1 = @"宽鼻";
static NSString *RESULT_NOSE_2 = @"窄鼻";
static NSString *RESULT_NOSE_3 = @"标准鼻";

NSString *p_GetNoseType(CGFloat radio) {
    if (radio > 1.1f) {
        return RESULT_NOSE_1;
    }
    else if (radio < 1.0f) {
        return RESULT_NOSE_2;
    }
    return RESULT_NOSE_3;
}


