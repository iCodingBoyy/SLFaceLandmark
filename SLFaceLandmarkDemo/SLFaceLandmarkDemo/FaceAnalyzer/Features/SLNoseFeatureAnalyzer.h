//
//  SLNoseFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 "nose": {
         "noseHeight": "188.00",
         "noseType": "标准鼻",
         "noseWidth": "154.00",
         "philtrumWidth": "54.00"
     },
 */

@interface SLNoseFeature : NSObject <SLFeatureDelegate>
@property (nonatomic, assign) CGFloat noseWidth; ///< 鼻翼宽度
@property (nonatomic, assign) CGFloat noseHeight; ///< 鼻子长度
@property (nonatomic, assign) CGFloat philtrumWidth; ///< 人中长度
@property (nonatomic, strong) NSString *noseType; ///< 鼻型
@end


/// 鼻子特征分析
/// 点 83, 82, 49, 43, 87, 58, 55
@interface SLNoseFeatureAnalyzer : SLBaseAnalyzer
+ (SLNoseFeature*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
