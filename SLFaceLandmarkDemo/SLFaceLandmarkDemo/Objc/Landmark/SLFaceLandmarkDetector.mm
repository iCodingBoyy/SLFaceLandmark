//
//  SLFaceLandmarkDetector.m
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs/ios.h>
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#import "SLFaceLandmarkDetector.h"
#include <SLFaceLandmark/sl_facelandmark.h>
#include <SLFaceLandmark/sl_common.h>
//#include "mediapipe/core/cpp/sl_facelandmark.h"
//#include "mediapipe/core/cpp/sl_common.h"
#include <iostream>
#import "SLSDKAuthProvider.h"

static NSString *SLFaceLandmarkErrorDomain = @"SLFaceLandmarkErrorDomain";
static NSString* const kSLGraphName = @"face_landmark_opencv_tracking_mobile_gpu";

using namespace sl_facelandmark;
using namespace std;

@interface SLFaceLandmarkDetector ()
@property (nonatomic, assign) SL_FACELANDMARK_API_HANDLE detectHandle;
@property (nonatomic, strong) SLFaceLandmarkConfig *faceLandmarkConfig;
@end

@implementation SLFaceLandmarkDetector

#pragma mark - init

- (void)dealloc {
    [[SLSDKAuthProvider shared]resetCacheAuthState];
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        sl_init();
        // 首次初始化同步一次授权信息
        [[SLSDKAuthProvider shared]syncAuthInfo];
    }
    return self;
}

#pragma mark - error

- (SLErrorCode)errorCodeFromRetCode:(SL_RETCODE)retCode {
    if (retCode == SL_RETCODE_OK) {
        return SLErrorCodeNoError;
    }
    else if (retCode == SL_RETCODE_INVALID_ARGUMENT) {
        return SLErrorCodeInvalidArguments;
    }
    else if (retCode == SL_RETCODE_INVALID_HANDLE ||
             retCode == SL_RETCODE_INVALID_MODEL ) {
        return SLErrorCodeInitializeGraphFailed;
    }
    return SLErrorCodeDetectionFailed;
}


#pragma mark - prepare graph

- (BOOL)prepareGraphInBundle:(NSBundle*)bundle error:(NSError**)error {
    if (!bundle) {
        if (*error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"请输入有效的 bundle 路径"};
            *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                         code:SLErrorCodeInvalidArguments userInfo:userInfo];
        }
        return NO;
    }
    NSString *path = [@"Frameworks/SLFaceLandmark.framework/" stringByAppendingString:kSLGraphName];
    NSURL *graphURL = [bundle URLForResource:path withExtension:@"binarypb"];
    NSData *graphData = [NSData dataWithContentsOfURL:graphURL options:0 error:error];
    if (!graphData) {
        if (*error) {
            NSString *reason = [NSString stringWithFormat:@"在[%@]路径下未找到可用的 Graph 模型",bundle.bundlePath];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:reason};
            *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                         code:SLErrorCodeInvalidModelFile userInfo:userInfo];
        }
        return NO;
    }
    Byte *pbBytes = (Byte*)[graphData bytes];
    int32_t pblen = (int32_t)graphData.length;
    
    SL_RETCODE retCode = my_facelandmark.createApiHandle(pbBytes, pblen, &_detectHandle);
    if (retCode != SL_RETCODE_OK) {
        SLErrorCode errorCode = [self errorCodeFromRetCode:retCode];
        NSString *reason = @"检测器模型初始化失败";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:reason};
        *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                     code:errorCode userInfo:userInfo];
        return NO;
    }
    return YES;
}


#pragma mark - run

- (BOOL)openWithConfig:(SLFaceLandmarkConfig *)config error:(NSError *__autoreleasing  _Nullable *)error {
    if (!config) {
        if (error != nullptr) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"请输入有效的 config 文件"};
            *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                         code:SLErrorCodeInvalidArguments userInfo:userInfo];
        }
        return NO;
    }
    
    SLAuthorizationState authState = [SLSDKAuthProvider shared].authState;
    if (authState != SLAuthorizationStateAuthorized) {
        if (error != nullptr) {
            NSInteger code = SLErrorCodeSDKVerifyFailed;
            NSString *errorDesc = @"SDK授权验证失败";
            if (authState == SLAuthorizationStateUnAuthorized) {
                code = SLErrorCodeSDKUnAuthorized;
                errorDesc = @"SDK未取得授权";
            }
            else if (authState == SLAuthorizationStateExpired) {
                code = SLErrorCodeSDKAuthorizationExpired;
                errorDesc = @"SDK授权过期";
            }
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorDesc};
            *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:code userInfo:userInfo];
        }
        return NO;
    }
    self.faceLandmarkConfig = config;
    
    SL_APICONFIG apiConfig;
    apiConfig.min_face_size = config.minFaceSize;
    apiConfig.rotation = (SL_ROTATION)config.rotation;
    apiConfig.interval = config.interval;
    apiConfig.detection_mode = (SL_DETECTIONMODE)config.detectionMode;
    apiConfig.face_confidence_filter = config.faceConfidenceFilter;
    
    SL_RECTANGLE rectangle;
    rectangle.left = config.roi.left;
    rectangle.top = config.roi.top;
    rectangle.width = config.roi.width;
    rectangle.height = config.roi.height;
    apiConfig.roi = rectangle;
    
    SL_RETCODE retCode = my_facelandmark.setConfig(_detectHandle,&apiConfig);
    if (retCode != SL_RETCODE_OK) {
        SLErrorCode errorCode = [self errorCodeFromRetCode:retCode];
        NSString *reason = @"检测器打开失败";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:reason};
        *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                     code:errorCode userInfo:userInfo];
        return NO;
    }
    return YES;
}

- (void)close {
    [[SLSDKAuthProvider shared]resetCacheAuthState];
    my_facelandmark.releaseApiHandle(_detectHandle);
}

#pragma mark - detection

- (void)detectWithDataFrame:(SL_DATA_FRAME*)dataFrame result:(void(^_Nullable)(SLFaceDetectionResult *result, NSError *error))retHandler {
    if (dataFrame == NULL) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"dataFrame = NULL,请确保输入有效的数据帧"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeInvalidArguments userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    SLAuthorizationState authState = [SLSDKAuthProvider shared].authState;
    if (authState != SLAuthorizationStateAuthorized) {
        if (retHandler) {
            NSInteger code = SLErrorCodeSDKVerifyFailed;
            NSString *errorDesc = @"SDK授权验证失败";
            if (authState == SLAuthorizationStateUnAuthorized) {
                code = SLErrorCodeSDKUnAuthorized;
                errorDesc = @"SDK未取得授权";
            }
            else if (authState == SLAuthorizationStateExpired) {
                code = SLErrorCodeSDKAuthorizationExpired;
                errorDesc = @"SDK授权过期";
            }
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorDesc};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:code userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    SL_IMAGE sl_image;
    sl_image.data = (*dataFrame).data;
    sl_image.data_length = (*dataFrame).data_length;
    sl_image.width = (*dataFrame).width;
    sl_image.height = (*dataFrame).height;
    sl_image.image_mode = (SL_IMAGEMODE)((*dataFrame).image_format);
    SL_RESULT sl_result;
    SL_RETCODE retCode = my_facelandmark.detectImage(_detectHandle, &sl_image,&sl_result);
//    NSLog(@"--retCode--%@",@(retCode));
    if (retCode != SL_RETCODE_OK) {
        if (sl_image.data != nullptr) {
            free(sl_image.data); sl_image.data = nullptr;(*dataFrame).data = nullptr;
        }
        if (retHandler) {
            SLErrorCode errorCode = [self errorCodeFromRetCode:retCode];
            NSString *reason = @"人脸框和关键点检测失败";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:reason};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:errorCode userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    if (sl_image.data != nullptr) {
        free(sl_image.data); sl_image.data = nullptr;(*dataFrame).data = nullptr;
    }
    if (sl_result.faces == nullptr || sl_result.face_num <= 0) {
        if (retHandler) {
            NSString *reason = @"无效的人脸框和关键点数据";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:reason};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeInvalidFacelandmarksData userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    // 转换结果
    SLFaceDetectionResult *result = [[SLFaceDetectionResult alloc]init];
    result.faceNum = (NSInteger)sl_result.face_num;
    NSMutableArray *facesArray = [[NSMutableArray alloc]init];
    for (int index = 0; index < result.faceNum; index++) {
        SL_FACE sl_face = sl_result.faces[index];
        
        SLFace *face = [[SLFace alloc]init];
//        CGFloat width = MAX(0, sl_face.roi.right - sl_face.roi.left);
//        CGFloat height = MAX(0, sl_face.roi.bottom - sl_face.roi.top);
        face.faceRect = CGRectMake(sl_face.roi.left, sl_face.roi.top, sl_face.roi.width, sl_face.roi.height);
        NSMutableArray *pointsArray = [[NSMutableArray alloc]init];
        for (int index = 0; index < sl_face.landmark_num; index++) {
            SL_POINT sl_point = sl_face.landmarks[index];
            CGPoint point = CGPointMake(sl_point.x, sl_point.y);
            [pointsArray addObject:[NSValue valueWithCGPoint:point]];
        }
        face.landmarks = [NSArray arrayWithArray:pointsArray];
        [facesArray addObject:face];
    }
    result.faces = [NSArray arrayWithArray:facesArray];
    if (sl_result.faces) {
        delete sl_result.faces;
    }
    if (retHandler) {
        retHandler(result, nil);
    }
    
}


- (void)detectWithFaceImage:(nullable UIImage*)image result:(void(^_Nullable)(SLFaceDetectionResult  *result, NSError *error))retHandler {
    if(!image) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"image == nil, 请确保输入图片不为空"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeInvalidArguments userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    if (self.faceLandmarkConfig.detectionMode != SLFaceDetectionModeImage &&
        self.faceLandmarkConfig.detectionMode != SLFaceDetectionModeImageOnlyFaceRect) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"仅支持静态图片人脸检测"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeUnsupportedDetectionMode userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    SLAuthorizationState authState = [SLSDKAuthProvider shared].authState;
    if (authState != SLAuthorizationStateAuthorized) {
        if (retHandler) {
            NSInteger code = SLErrorCodeSDKVerifyFailed;
            NSString *errorDesc = @"SDK授权验证失败";
            if (authState == SLAuthorizationStateUnAuthorized) {
                code = SLErrorCodeSDKUnAuthorized;
                errorDesc = @"SDK未取得授权";
            }
            else if (authState == SLAuthorizationStateExpired) {
                code = SLErrorCodeSDKAuthorizationExpired;
                errorDesc = @"SDK授权过期";
            }
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorDesc};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:code userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    CGImageRef cgImage = image.CGImage;
    size_t frameWidth = CGImageGetWidth(cgImage);
    size_t frameHeight = CGImageGetHeight(cgImage);
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    if (imageMat.empty()) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"无效的image图片,提取的字节为空"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeInvalidArguments userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    cv::Mat RGBAMat;
    cv::cvtColor(imageMat, RGBAMat, CV_BGR2RGBA);
    size_t byteSize = RGBAMat.total() * RGBAMat.elemSize();
    void *imageBytes = malloc(byteSize);
    memcpy(imageBytes, RGBAMat.data, byteSize);
    
    // 数据包转换
    SL_DATA_FRAME sl_data_frame;
    sl_data_frame.width = (int32_t)frameWidth;
    sl_data_frame.height = (int32_t)frameHeight;
    sl_data_frame.rotation_angle = SL_ROTATION_ANGLE_0;
    sl_data_frame.image_format = SL_IMAGE_FORMAT_RGBA;
    sl_data_frame.data = (uint8_t*)imageBytes;
    sl_data_frame.data_length = (int32_t)byteSize;
    
    [self detectWithDataFrame:&sl_data_frame result:retHandler];
}

- (void)detectWithVideoBuffer:(nullable CVPixelBufferRef)pixelBuffer result:(void(^_Nullable)(SLFaceDetectionResult  *result, NSError *error))retHandler {
    if (pixelBuffer == nullptr) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"pixelBuffer == nil, 输入buffer不能为空"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeInvalidArguments userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    if (self.faceLandmarkConfig.detectionMode != SLFaceDetectionModeVideoTracking &&
        self.faceLandmarkConfig.detectionMode != SLFaceDetectionModeVideoTrackingOnlyFaceRect) {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"仅支持视频帧人脸检测"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeUnsupportedDetectionMode userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    SLAuthorizationState authState = [SLSDKAuthProvider shared].authState;
    if (authState != SLAuthorizationStateAuthorized) {
        if (retHandler) {
            NSInteger code = SLErrorCodeSDKVerifyFailed;
            NSString *errorDesc = @"SDK授权验证失败";
            if (authState == SLAuthorizationStateUnAuthorized) {
                code = SLErrorCodeSDKUnAuthorized;
                errorDesc = @"SDK未取得授权";
            }
            else if (authState == SLAuthorizationStateExpired) {
                code = SLErrorCodeSDKAuthorizationExpired;
                errorDesc = @"SDK授权过期";
            }
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorDesc};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:code userInfo:userInfo];
            retHandler(nil, error);
        }
        return;
    }
    
    OSType pixelType = CVPixelBufferGetPixelFormatType(pixelBuffer);
//    kCVPixelFormatType_24RGB          = 0x00000018, /* 24 bit RGB */
//    kCVPixelFormatType_24BGR          = '24BG',     /* 24 bit BGR */
//    kCVPixelFormatType_32ARGB         = 0x00000020, /* 32 bit ARGB */
//    kCVPixelFormatType_32BGRA         = 'BGRA',     /* 32 bit BGRA */
//    kCVPixelFormatType_32ABGR         = 'ABGR',     /* 32 bit ABGR */
//    kCVPixelFormatType_32RGBA         = 'RGBA',     /* 32 bit RGBA */
    if (pixelType == kCVPixelFormatType_24RGB || pixelType == kCVPixelFormatType_24BGR ||
        pixelType == kCVPixelFormatType_32BGRA || pixelType == kCVPixelFormatType_32RGBA) {
        
        int type = (pixelType == kCVPixelFormatType_24RGB || pixelType == kCVPixelFormatType_24BGR) ? CV_8UC3 :CV_8UC4;
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        UInt8 *baseAddress = (UInt8*)CVPixelBufferGetBaseAddress(pixelBuffer);
        int pixelWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int pixelHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
        int dataSize = (int)CVPixelBufferGetDataSize(pixelBuffer);
        cv::Size size = cv::Size(pixelWidth, pixelHeight);
        cv::Mat intputMat = cv::Mat(size, type, baseAddress,bytesPerRow);
        
        cv::Mat copyMat;
        intputMat.copyTo(copyMat);
        
        SL_IMAGE_FORMAT image_format;
        if (pixelType == kCVPixelFormatType_24RGB) {
//            image_format = SL_IMAGE_FORMAT_RGB;
            cv::cvtColor(copyMat, copyMat, CV_RGB2RGBA);
        }
        else if (pixelType == kCVPixelFormatType_24BGR) {
//            image_format = SL_IMAGE_FORMAT_BGR;
            cv::cvtColor(copyMat, copyMat, CV_BGR2RGBA);
        }
        else if (pixelType == kCVPixelFormatType_32BGRA) {
//            image_format = SL_IMAGE_FORMAT_BGRA;
            cv::cvtColor(copyMat, copyMat, CV_BGRA2RGBA);
        }
        else {
            image_format = SL_IMAGE_FORMAT_RGBA;
        }
        
        size_t byteSize = copyMat.total() * copyMat.elemSize();
        void* target_data = malloc(dataSize);
        memcpy(target_data,copyMat.data,byteSize);
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        
        SL_DATA_FRAME sl_data_frame;
        sl_data_frame.width = (int32_t)pixelWidth;
        sl_data_frame.height = (int32_t)pixelHeight;
        sl_data_frame.rotation_angle = SL_ROTATION_ANGLE_0;
        sl_data_frame.image_format = SL_IMAGE_FORMAT_RGBA;
        sl_data_frame.data = (uint8_t*)target_data;
        sl_data_frame.data_length = (int32_t)byteSize;
        
        [self detectWithDataFrame:&sl_data_frame result:retHandler];
    }
    else if (pixelType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ||
             pixelType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
             pixelType == kCVPixelFormatType_420YpCbCr8Planar ||
             pixelType == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange ||
             pixelType == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange) {
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        UInt8 *baseAddress = (UInt8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
        int pixelWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer,0);
        int pixelHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer,0);
        int bytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);

        // pixelbuffer转换为gray矩阵
        cv::Size size = cv::Size(pixelWidth, pixelHeight);
        cv::Mat yuvMat = cv::Mat(size, CV_8UC1, baseAddress,bytesPerRow);
        
        cv::Mat rgbaMat;
        yuvMat.copyTo(rgbaMat);
        cv::cvtColor(rgbaMat, rgbaMat, CV_GRAY2RGBA);
        
        size_t byteSize = rgbaMat.total() * rgbaMat.elemSize();
        void* target_data = malloc(byteSize);
        memcpy(target_data, rgbaMat.data,byteSize);
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        
        
        SL_DATA_FRAME sl_data_frame;
        sl_data_frame.width = (int32_t)pixelWidth;
        sl_data_frame.height = (int32_t)pixelHeight;
        sl_data_frame.rotation_angle = SL_ROTATION_ANGLE_0;
        sl_data_frame.image_format = SL_IMAGE_FORMAT_RGBA;
        sl_data_frame.data = (uint8_t*)target_data;
        sl_data_frame.data_length = (int32_t)byteSize;
        
        [self detectWithDataFrame:&sl_data_frame result:retHandler];
        
        if (sl_data_frame.data) {
            free(sl_data_frame.data); sl_data_frame.data = nullptr;
        }
    }
    else {
        if (retHandler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"当前格式不支持，只支持YUV 4:2:0, 24位RGB、BGR，32位RBGA,BGRA"};
            NSError *error = [NSError errorWithDomain:SLFaceLandmarkErrorDomain
                                                 code:SLErrorCodeUnsupportedVideoFormat userInfo:userInfo];
            retHandler(nil, error);
        }
    }
}

bool writeImage2Document(const char *imageName, cv::Mat img) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%s.jpg", imageName]];
    const char* cPath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
    const cv::String newPaths = (const cv::String)cPath;
    
    //Save as Bitmap to Documents-Directory
    cv::imwrite(newPaths, img);
    return true;
}
@end


