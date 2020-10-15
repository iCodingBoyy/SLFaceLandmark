//
//  SLEyeBrowFeatureAnalyzer.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLEyeBrowFeatureAnalyzer.h"

@implementation SLEyeBrowFeature

- (NSDictionary*)JSONObject {
    return nil;
}

- (BOOL)isEqualToFeature:(id)object {
    return NO;
}
@end

@implementation SLEyeBrowFeatureAnalyzer
+ (SLEyeBrowFeature*)analysisInLandmarks:(nullable NSArray*)landmarks {
    
    SLEyeBrowFeature *feature = [[SLEyeBrowFeature alloc]init];
    return feature;
}
@end
