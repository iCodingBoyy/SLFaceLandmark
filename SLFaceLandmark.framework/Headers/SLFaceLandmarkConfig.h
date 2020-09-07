//
//  SLFaceLandmarkConfig.h
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLFaceLandmarkDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    int32_t left;              ///< 矩形框最左边的坐标值
    int32_t top;               ///< 矩形框最上边的坐标值
    int32_t right;             ///< 矩形框最右边的坐标值
    int32_t bottom;            ///< 矩形框最下边的坐标值
} SLRectangle;


typedef NS_ENUM(NSInteger, SLFaceDetectionMode) {
    SLFaceDetectionModeImage,  ///< 单张图片人脸检测模式
    SLFaceDetectionModeVideoTracking, ///< 视频人脸跟踪模式
    SLFaceDetectionModeImageOnlyFaceRect, ///< 单张图片单纯检测人脸框
    SLFaceDetectionModeVideoTrackingOnlyFaceRect, ///< 视频动态检测人脸框
};


@interface SLFaceLandmarkConfig : NSObject

/// 最小检测人脸的尺寸（人脸尺寸一般是指人脸脸颊的宽度）
/// 数值越大检测用的耗时越少。
@property (nonatomic, assign) UInt32 minFaceSize;

/// 输入图像的重力方向，必须是 90 的倍数。
/// 表示输入图像顺时针旋转 rotation 度之后为正常的重力方向。
/// 推荐使用的数值：0, 90, 180, 270, 360
@property (nonatomic, assign) SL_ROTATION_ANGLE rotation;

/// 在 SL_FPP_DETECTIONMODE_TRACKING 模式下才有效。
/// 表示每隔多少帧进行一次全图的人脸检测。
/// 其余时间只对原有人脸进行跟踪。
@property (nonatomic, assign) UInt32 interval;

/// 人脸检测模式，可见 SLFaceDetectionMode 类型。
@property (nonatomic, assign) SLFaceDetectionMode detectionMode;

/// 一个矩形框，表示只对图像中 roi 所表示的区域做人脸检测。
/// 在特定场景下，此方法可以提高检测速度。
/// 如果人脸在 roi 中被检测到，且移动到了 roi 之外的区域，依然可以被跟踪。
@property (nonatomic, assign) SLRectangle roi;

/// 人脸置信度过滤阈值，低于此值的数据将被过滤掉，默认 0.1
@property (nonatomic, assign) float faceConfidenceFilter;

@end

NS_ASSUME_NONNULL_END
