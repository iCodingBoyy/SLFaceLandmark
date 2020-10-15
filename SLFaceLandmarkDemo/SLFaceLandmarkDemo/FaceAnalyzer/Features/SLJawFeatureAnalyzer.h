//
//  SLJawFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLJawFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat jawAngle;
@property (nonatomic, assign) CGFloat jawLength;
@property (nonatomic, assign) CGFloat jawWidth;
@property (nonatomic, strong) NSString *jawType;
@end

@interface SLJawFeatureAnalyzer : SLBaseAnalyzer
+ (SLJawFeature*)analysisInLandmarks:(NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
