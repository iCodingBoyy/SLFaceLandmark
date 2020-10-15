#ifndef _SL_COMMON_H
#define _SL_COMMON_H

#ifndef SL_BASIC_TYPES
#if defined(unix) || defined(__unix__) || defined(__unix) || defined (__APPLE__) || defined(__MINGW_GCC) || defined(__MINGW32__)
#include <stdint.h>
    typedef int8_t             SL_INT8;
    typedef int16_t            SL_INT16;
    typedef int32_t            SL_INT32;
    typedef int64_t            SL_INT64;
    typedef uint8_t            SL_UINT8;
    typedef uint16_t           SL_UINT16;
    typedef uint32_t           SL_UINT32;
    typedef uint64_t           SL_UINT64;
#elif defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
#include <windows.h>
    typedef signed __int8      SL_INT8;
    typedef signed __int16     SL_INT16;
    typedef signed __int32     SL_INT32;
    typedef signed __int64     SL_INT64;
    typedef unsigned __int8    SL_UINT8;
    typedef unsigned __int16   SL_UINT16;
    typedef unsigned __int32   SL_UINT32;
    typedef unsigned __int64   SL_UINT64;
#else
typedef signed char SL_INT8;
typedef signed char* SL_INT8_PTR;
typedef signed short SL_INT16;
typedef int SL_INT32;
typedef long long SL_INT64;
typedef unsigned char SL_UINT8;
typedef unsigned short SL_UINT16;
typedef unsigned int SL_UINT32;
typedef unsigned long long SL_UINT64;
#endif

typedef float SL_SINGLE;
typedef double SL_DOUBLE;
typedef unsigned char SL_BYTE;
typedef int SL_BOOL;
#ifndef NULL
#define NULL 0
#endif
#define SL_BASIC_TYPES
#endif

#if __APPLE__
#define MGAPI_BUILD_ON_IPHONE   1

#elif __ANDROID__
#define MGAPI_BUILD_ON_ANDROID	1
#include <jni.h>
#elif __linux
#define MGAPI_BUILD_ON_LINUX    1
#else
#error "unsupported platform"
#endif


namespace sl_facelandmark {
    typedef enum {
        SL_RETCODE_OK = 0,              ///< 正确运行程序

        SL_RETCODE_INVALID_ARGUMENT,    ///< 传入了非法的参数

        SL_RETCODE_INVALID_HANDLE,      ///< 传入了非法的句柄（handle）

        SL_RETCODE_INDEX_OUT_OF_RANGE,  ///< 传入了非法的索引（index）

        SL_RETCODE_EXPIRE = 101,        ///< SDK已过期，函数无法正常运行

        SL_RETCODE_INVALID_BUNDLEID,    ///< 检测到包名与SDK所限制的包名不符

        SL_RETCODE_INVALID_LICENSE,     ///< 传入了错误的证书（license）

        SL_RETCODE_INVALID_MODEL,       ///< 传入了错误的模型（model）

        SL_RETCODE_FAILED = -1,         ///< 算法内部错误
    } SL_RETCODE;



    /**
    * @brief 坐标点类型
    *
    * 表示一个二维平面上的坐标（笛卡尔坐标系）。
    */
    typedef struct {
        SL_SINGLE x;                ///< 坐标点x轴的值
        SL_SINGLE y;                ///< 坐标点y轴的值
    } SL_POINT;

    /**
    * @brief 坐标点类型
    *
    * 表示一个二维平面上的大小。
    */
    typedef struct {
        SL_INT32 width;                ///< 宽
        SL_INT32 height;                ///< 高
    } SL_SIZE;

    /**
    * @brief 图像中平行于量坐标轴的矩形框
    * 在图像中表示一个双边平行于坐标轴的矩形框，
    */
    typedef struct {
        SL_INT32 left;              ///< 矩形框最左边的坐标值
        SL_INT32 top;               ///< 矩形框最上边的坐标值
        SL_INT32 width;             ///< 矩形框宽度
        SL_INT32 height;            ///< 矩形框高度
    } SL_RECTANGLE;

    /**
    * @brief 图像格式类型
    *
    * 表示图像数据格式的枚举类型，支持几种常见的图像格式。
    */
    typedef enum {
        SL_IMAGEMODE_NV12,
        SL_IMAGEMODE_NV21,
        SL_IMAGEMODE_RGB,
        SL_IMAGEMODE_BGR,
        SL_IMAGEMODE_RGBA,
        SL_IMAGEMODE_BGRA,
        SL_IMAGEMODE_GRAY
    } SL_IMAGEMODE;

    typedef enum {
        SL_ROTATION_0 = 0,                              ///< 不旋转

        SL_ROTATION_90 = 90,                            ///< 图像右时针旋转 90 度

        SL_ROTATION_180 = 180,                          ///< 图像右时针旋转 180 度

        SL_ROTATION_270 = 270,                          ///< 图像右时针旋转 270 度
    } SL_ROTATION;

}
#endif
