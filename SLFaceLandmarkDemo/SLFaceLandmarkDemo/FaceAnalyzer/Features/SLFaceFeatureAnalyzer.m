//
//  SLFaceFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLFaceFeatureAnalyzer.h"


#pragma mark - SLFaceFeature

@implementation SLFaceFeature
- (NSDictionary*)JSONObject {
    return nil;
}

- (BOOL)isEqualToFeature:(id)object {
    return NO;
}
@end


#pragma mark - SLFaceFeatureAnalyzer

@implementation SLFaceFeatureAnalyzer
+ (SLFaceFeature*)analysisInLandmarks:(nullable NSArray*)landmarks {
    
    SLFaceFeature *feature = [[SLFaceFeature alloc]init];
    
    return feature;
}
@end
