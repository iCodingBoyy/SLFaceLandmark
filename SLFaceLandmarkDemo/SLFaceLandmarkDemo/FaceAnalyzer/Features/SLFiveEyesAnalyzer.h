//
//  SLFiveEyesAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLEyePart : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) NSString *result;
@end

@interface SLFiveEyes : NSObject <SLFeatureDelegate>
@property (nonatomic, strong) NSString *eyesRatio;
/// 左眼外侧
@property (nonatomic, strong) SLEyePart *fiveEye;
@property (nonatomic, strong) SLEyePart *leftEye;
@property (nonatomic, strong) SLEyePart *rightEye;
/// 右眼外侧
@property (nonatomic, strong) SLEyePart *oneEye;
/// 内眼角间距
@property (nonatomic, strong) SLEyePart *threeEye;
@end

@interface SLFiveEyesAnalyzer : SLBaseAnalyzer
+ (SLFiveEyes*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
