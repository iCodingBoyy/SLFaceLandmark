//
//  SLFaceLandmarkDefine.h
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#ifndef SLFaceLandmarkDefine_h
#define SLFaceLandmarkDefine_h

typedef enum {
    SL_ROTATION_ANGLE_0 = 0,       ///< 不旋转
    SL_ROTATION_ANGLE_90 = 90,     ///< 图像右时针旋转 90 度
    SL_ROTATION_ANGLE_180 = 180,   ///< 图像右时针旋转 180 度
    SL_ROTATION_ANGLE_270 = 270,   ///< 图像右时针旋转 270 度
} SL_ROTATION_ANGLE;

typedef enum {
    SL_IMAGE_FORMAT_NV12,
    SL_IMAGE_FORMAT_NV21,
    SL_IMAGE_FORMAT_RGB,  ///< 24位 RGB
    SL_IMAGE_FORMAT_BGR,  ///< 24位 BGR
    SL_IMAGE_FORMAT_RGBA, ///< 32位 RGBA
    SL_IMAGE_FORMAT_BGRA, ///< 32位 BGRA
    SL_IMAGE_FORMAT_GRAY  ///< 灰度图像
} SL_IMAGE_FORMAT;

typedef struct {
    uint8_t *data;  ///< 输入的图像字节或者buffer数据
    int32_t data_length;
    int32_t width;
    int32_t height;
    SL_ROTATION_ANGLE rotation_angle; ///< 图像旋转角度
    SL_IMAGE_FORMAT image_format;
} SL_DATA_FRAME;


typedef NS_ENUM(NSInteger, SLErrorCode) {
    SLErrorCodeNoError,
    SLErrorCodeInvalidArguments,        ///< 无效的参数
    SLErrorCodeInvalidModelFile,        ///< 无效的模型文件
    SLErrorCodeInvalidAuthorization,    ///< 无效的授权信息
    SLErrorCodeInitializeGraphFailed,   ///< 初始化模型文件失败
    SLErrorCodeUnsupportedVideoFormat,   ///< 不支持的视频格式
    SLErrorCodeUnsupportedDetectionMode, ///< 不支持的检测模式
    SLErrorCodeDetectionFailed,          ///< 检测失败
    SLErrorCodeInvalidFacelandmarksData, ///< 无效的特征点数据
    
};

#endif /* SLFaceLandmarkDefine_h */
