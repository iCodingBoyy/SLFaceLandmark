//
//  SLFaceFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLFaceFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat faceLength;
@property (nonatomic, assign) CGFloat mandibleLength;
@property (nonatomic, assign) CGFloat mandibleAngle;
@property (nonatomic, assign) CGFloat tempusLength;
@property (nonatomic, assign) CGFloat zygomaLength;
@property (nonatomic, strong) NSString *ratio;
@end

@interface SLFaceFeatureAnalyzer : SLBaseAnalyzer
+ (SLFaceFeature*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
