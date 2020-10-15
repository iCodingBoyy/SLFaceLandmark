#ifndef _SL_FACELANDMARK_H
#define _SL_FACELANDMARK_H

#include "sl_common.h"

namespace sl_facelandmark {

#define DEFAULT_DETECT_FACE_POINT_HET 127
/**
 * @brief 人脸检测模式类型
 * 
 * 支持对单张图片做人脸检测，也支持对视频流做人脸检测。
 */
    typedef enum {
        SL_DETECTIONMODE_NORMAL = 0,             ///< 单张图片人脸检测模式
        SL_DETECTIONMODE_TRACKING = 1,           ///< 视频人脸跟踪模式
        SL_DETECTIONMODE_RECT_ONLY = 2,          ///< 单张单纯检测人脸框
        SL_DETECTIONMODE_RECT_ONLY_TRACKING = 3, ///< 动态检测人脸框
    } SL_DETECTIONMODE;

    typedef struct {
        SL_UINT8 *data;
        SL_INT32 data_length;
        SL_INT32 width;
        SL_INT32 height;
        SL_IMAGEMODE image_mode;
    } SL_IMAGE;

    typedef struct {
        SL_POINT landmarks[DEFAULT_DETECT_FACE_POINT_HET];
        SL_INT8 landmark_num;
        SL_RECTANGLE roi;
    } SL_FACE;

    typedef struct {
        SL_FACE *faces;
        SL_INT32 face_num;
    } SL_RESULT;

/**
 * @brief 人脸检测算法配置类型 
 * 
 * 可以对人脸检测算法进行配置。
 */
    typedef struct {
        SL_UINT32 min_face_size;                ///< 最小检测人脸的尺寸（人脸尺寸一般是指人脸脸颊的宽度）。
        ///< 数值越大检测用的耗时越少。

        SL_ROTATION rotation;                     ///< 输入图像的重力方向，必须是 90 的倍数。
        ///< 表示输入图像顺时针旋转 rotation 度之后为正常的重力方向。
        ///< 推荐使用的数值：0, 90, 180, 270, 360

        SL_UINT32 interval;                     ///< 在 SL_FPP_DETECTIONMODE_TRACKING 模式下才有效。
        ///< 表示每隔多少帧进行一次全图的人脸检测。
        ///< 其余时间只对原有人脸进行跟踪。

        SL_DETECTIONMODE detection_mode;    ///< 人脸检测模式，可见 SL_FPP_DETECTIONMODE 类型。

        SL_RECTANGLE roi;                       ///< 一个矩形框，表示只对图像中 roi 所表示的区域做人脸检测。
        ///< 在特定场景下，此方法可以提高检测速度。
        ///< 如果人脸在 roi 中被检测到，且移动到了 roi 之外的区域，依然可以被跟踪。

        SL_SINGLE face_confidence_filter;       ///< 人脸置信度过滤阈值，低于此值的数据将被过滤掉，默认 0.1

    } SL_APICONFIG;

    typedef long SL_FACELANDMARK_API_HANDLE;

    typedef struct {

        SL_RETCODE (*createApiHandle)(const SL_UINT8 *model, const SL_INT32 model_length,
                                      SL_FACELANDMARK_API_HANDLE *out_apiHandle);

        SL_RETCODE (*setConfig)(SL_FACELANDMARK_API_HANDLE apiHandle, SL_APICONFIG *apiconfig);

        SL_RETCODE (*detectImage)(SL_FACELANDMARK_API_HANDLE apiHandle, SL_IMAGE *image, SL_RESULT *out_result);

        SL_RETCODE (*releaseApiHandle)(SL_FACELANDMARK_API_HANDLE apiHandle);

    } SL_FACELANDMARK_API;


    void sl_init(
#if defined(__ANDROID__)
            JNIEnv* env,jobject context,jstring cache_dir_path
#endif
    );

    extern SL_FACELANDMARK_API my_facelandmark;

}
#endif
