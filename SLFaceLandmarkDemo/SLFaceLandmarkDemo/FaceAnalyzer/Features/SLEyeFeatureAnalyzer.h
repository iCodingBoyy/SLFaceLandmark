//
//  SLEyeFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLEyeFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat eyeHeight;
@property (nonatomic, assign) CGFloat eyeWidth;
@property (nonatomic, assign) CGFloat oculiMedialisAngle;
@end

@interface SLEyeFeatureAnalyzer : SLBaseAnalyzer
+ (SLEyeFeature*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
