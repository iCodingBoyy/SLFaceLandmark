//
//  SLEyeBrowFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLEyeBrowFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat browCamberAngle;
@property (nonatomic, assign) CGFloat browHeight;
@property (nonatomic, assign) CGFloat browThick;
@property (nonatomic, assign) CGFloat browUptrendAngle;
@property (nonatomic, assign) CGFloat browWidth;
@end

@interface SLEyeBrowFeatureAnalyzer : SLBaseAnalyzer
+ (SLEyeBrowFeature*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
