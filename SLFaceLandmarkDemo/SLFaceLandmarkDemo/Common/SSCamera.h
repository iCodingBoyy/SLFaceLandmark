//
//  SSCamera.h
//  SSSkinAnalysis
//
//  Created by 远征 马 on 2020/5/13.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SSFaceObject.h"

/// 相机页面，用于肌肤秘诀的相机拍照
@interface SSCamera : NSObject
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, assign, readonly) BOOL isPrepared;
@property (nonatomic,   copy) void (^didOutputSampleBufferBlock)(AVCaptureOutput *output, CMSampleBufferRef sampleBuffer, NSArray <SSFaceObject*>*faceInfoArray, AVCaptureConnection *connection);

/// 初始化相机
/// @param error 返回 NO 时 你可以检查error信息
/// @warning 如果此处初始化失败，请退出当前相机界面
- (BOOL)prepareCamera:(AVCaptureDevicePosition)position error:(NSError**)error;


- (void)clear;

- (void)focusAndExposureAtPoint:(CGPoint)focusPoint;

#pragma mark - running

- (BOOL)isRunning;

/// 同步启动视频帧录制
- (void)startRunningSynchronously;

/// 异步开始视频帧录制
- (void)startRunning;

- (void)stopRunning;

#pragma mark - position

/// 判断是否是后置摄像头
- (BOOL)isCameraPositionBack;


/// 获取摄像头位置
- (AVCaptureDevicePosition)getCameraPosition;


#pragma mark - config

/// 异步切换摄像头方向
/// @param position 摄像头位置
/// @warning 当切换失败或返回原摄像头方向，切换成功返回新的方向
- (void)setCameraPosition:(AVCaptureDevicePosition)position result:(void(^)(AVCaptureDevicePosition position))retHandler;


/// 设置照片规格
/// @param sessionPreset 见AVCaptureSessionPreset
- (BOOL)setSessionPreset:(AVCaptureSessionPreset)sessionPreset;


/// 设置视频录制格式
/// @param videoSettings 格式
- (void)setVideoSettings:(NSDictionary<NSString *, id>*)videoSettings;


#pragma mark - 异步拍照


- (BOOL)isCapturingStillImage;


/// 异步拍摄照片
/// @param completionHandler 拍照buffer回调
/// @param retHandler 处理结果回调
- (void)takePhotosAsynchronously:(void(^)(CMSampleBufferRef imageDataSampleBuffer,NSError *error))completionHandler
                          result:(void(^)(NSData *imageData, NSError *error))retHandler;
/// 异步拍摄照片
/// @param retHandler 回调block
/// @warning 回调不在主线程，请注意切换到主线程刷新UI
- (void)takePhotosAsynchronously:(void(^)(NSData *imageData, NSError *error))retHandler;

@end
