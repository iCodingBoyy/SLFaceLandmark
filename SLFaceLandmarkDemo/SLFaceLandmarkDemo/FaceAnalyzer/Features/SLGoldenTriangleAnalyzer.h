//
//  SLGoldenTriangleAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLGoldenTriangleAnalyzer : SLBaseAnalyzer
+ (CGFloat)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
