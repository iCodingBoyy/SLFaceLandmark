//
//  SLMouthFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLMouthFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat angulusOris; ///< 嘴角弯曲度
@property (nonatomic, assign) CGFloat lipThickness;///< 嘴唇厚度
@property (nonatomic, assign) CGFloat mouthHeight;
@property (nonatomic, assign) CGFloat mouthWidth;
@property (nonatomic, strong) NSString *mouthType; ///< 唇型 (微笑唇 厚唇 标准唇)
@end


@interface SLMouthFeatureAnalyzer : SLBaseAnalyzer
+ (SLMouthFeature*)analysisInLandmarks:(nullable NSArray *)landmarks;
@end

NS_ASSUME_NONNULL_END
