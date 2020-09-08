//
//  AVCaptureDevice+SSDevice.m
//  CBeauty
//
//  Created by 远征 马 on 2020/5/26.
//  Copyright © 2020 wff. All rights reserved.
//

#import "AVCaptureDevice+SSDevice.h"
#import <UIKit/UIKit.h>

void SSDispatchAsyncMain(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@implementation AVCaptureDevice (SSDevice)
+ (AVAuthorizationStatus)SSCameraAuthStatus {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (void)SSRequestAccessForCamera:(void(^)(BOOL granted))retHandler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        SSDispatchAsyncMain(^{
            if (retHandler) {
                retHandler(granted);
            }
        });
    }];
}

+ (AVCaptureDevice*)SSGetCaptureDeviceWithPosition:(AVCaptureDevicePosition )position {
    NSArray *cameras = nil;
    #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            cameras = discoverySession.devices;
            #pragma clang diagnostic pop
        }
        else
        {
            cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        }
    #else
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            cameras = discoverySession.devices;
        }
        else
        {
            // Fallback on earlier versions
            cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        }
    #endif
        for (AVCaptureDevice *camera in cameras) {
            if ([camera position] == position) {
                return camera;
            }
        }
        return nil;
}

+ (AVCaptureDeviceInput*)SSGetCaptureDeviceInputWithPosition:(AVCaptureDevicePosition )position error:(NSError**)error {
    if (position != AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    }
    AVCaptureDevice *device = [self SSGetCaptureDeviceWithPosition:position];
    return [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
}

+ (NSUInteger)SSGetCameraCount {
    NSUInteger cameraCount = 0;
    #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            cameraCount = deviceSession.devices.count;
            #pragma clang diagnostic pop
        }
        else
        {
            cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
        }
    #else
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            cameraCount = deviceSession.devices.count;
        }
        else
        {
            cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
        }
    #endif
        return cameraCount;
}
@end
