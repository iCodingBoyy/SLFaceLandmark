//
//  SLEyeFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLEyeFeatureAnalyzer.h"

@implementation SLEyeFeature
- (NSDictionary*)JSONObject {
    return nil;
}

- (BOOL)isEqualToFeature:(id)object {
    return NO;
}

@end

@implementation SLEyeFeatureAnalyzer
+ (SLEyeFeature*)analysisInLandmarks:(nullable NSArray*)landmarks {
    
    SLEyeFeature *feature = [[SLEyeFeature alloc]init];
    
    return feature;
}
@end
