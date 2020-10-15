//
//  SLFacialFeatureAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/9/21.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 面部特征分析器，负责面部三庭五眼、形象等分析
@interface SLFacialFeatureAnalyzer : NSObject

/// 判断当前照片角度是否符合面部分析
/// @warning 人脸倾斜会影响面部特征检测，需要对照片进行转正分析
- (BOOL)isValidAngleForFaceFeatureAnalysis:(NSArray*)landmarks error:(NSError**)error;


/// 分析面部特征
/// @param landmarks 人脸关键点，包含127个点位
/// @param retHandler 分析结果回调
- (void)analysisWithLandmarks:(NSArray*)landmarks result:(void(^)(id result, NSError *error))retHandler;
@end

NS_ASSUME_NONNULL_END
