//
//  AVCaptureDevice+SSDevice.h
//  CBeauty
//
//  Created by 远征 马 on 2020/5/26.
//  Copyright © 2020 wff. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

FOUNDATION_EXPORT void SSDispatchAsyncMain(dispatch_block_t block);

@interface AVCaptureDevice (SSDevice)

/// 获取相机授权状态
+ (AVAuthorizationStatus)SSCameraAuthStatus;


/// 请求相机访问许可
/// @param retHandler 回调block
+ (void)SSRequestAccessForCamera:(void(^)(BOOL granted))retHandler;


/// 获取指定位置的captureDevice
/// @param position 见`AVCaptureDevicePosition`
+ (AVCaptureDevice*)SSGetCaptureDeviceWithPosition:(AVCaptureDevicePosition )position;


/// 获取指定方向的deviceInput
/// @param position 见`AVCaptureDevicePosition`
/// @param error 错误描述
+ (AVCaptureDeviceInput*)SSGetCaptureDeviceInputWithPosition:(AVCaptureDevicePosition )position error:(NSError**)error;


/// 获取设备摄像头数量
+ (NSUInteger)SSGetCameraCount;
@end

