//
//  SLFaceLandmarkDetector.h
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLFaceDetectionResult.h"
#import "SLFaceLandmarkConfig.h"
#import "SLFaceLandmarkDefine.h"

NS_ASSUME_NONNULL_BEGIN

/// 人脸特征点检测器，
@interface SLFaceLandmarkDetector : NSObject

/// 初始化检测模型
/// @param bundle 模型路径。在调用类传入[NSBundle bundleForClass:[self class]]即可
/// @param error 返回 NO，检查此错误信息
- (BOOL)prepareGraphInBundle:(nonnull NSBundle*)bundle error:(NSError**)error;


/// 打开检测器，正确初始化模型后需要调用此接口
/// @warning 请先调用`prepareGraphInBundle:error:`接口初始化
/// @param config 关键点检测配置
/// @param error 返回 NO，检查此错误信息
- (BOOL)openWithConfig:(nonnull SLFaceLandmarkConfig*)config error:(NSError**)error;


/// 关闭检测器
- (void)close;


/// 数据帧检测
/// @param dataFrame 包含高清人脸的数据帧
/// @param retHandler 检测结果回调
- (void)detectWithDataFrame:(SL_DATA_FRAME*)dataFrame result:(void(^_Nullable)(SLFaceDetectionResult  *result, NSError *error))retHandler;


/// 人脸静态图片检测
/// @@see SLFaceLandmarkConfig、SLFaceDetectionMode
/// @warning 当config.detectionMode 为图片检测时此设置有效
/// @param image 包含高清人脸的图片
/// @param retHandler 检测结果回调
- (void)detectWithFaceImage:(nullable UIImage*)image result:(void(^_Nullable)(SLFaceDetectionResult  *result, NSError *error))retHandler;


/// 视频帧关键点检测
/// @@see SLFaceLandmarkConfig、SLFaceDetectionMode
/// @warning 当config.detectionMode 为视频帧检测时此设置有效
/// @param pixelBuffer 视频帧buffer
/// @param retHandler 检测结果回调
- (void)detectWithVideoBuffer:(nullable CVPixelBufferRef)pixelBuffer result:(void(^_Nullable)(SLFaceDetectionResult  *result, NSError *error))retHandler;
@end

NS_ASSUME_NONNULL_END
