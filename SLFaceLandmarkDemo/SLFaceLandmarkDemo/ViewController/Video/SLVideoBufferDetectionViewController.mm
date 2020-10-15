//
//  SLVideoBufferDetectionViewController.m
//  SLFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/20.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <opencv2/imgproc.hpp>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import "SLVideoBufferDetectionViewController.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "AVCaptureDevice+SSDevice.h"
#import "SSCamera.h"
#import <CoreMedia/CoreMedia.h>
#import "SSGLKView.h"
#import "AVCaptureDevice+SSDevice.h"
#import <SLFaceLandmark/SLFaceLandmarkDetector.h>
//#import "SLFaceLandmarkDetector.h"


dispatch_queue_t SSBufferFaceDetectQueue(void) {
    static dispatch_queue_t facedetectQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [NSString stringWithFormat:@"com.SkinAnalysis.facedetectQueue-%@", [[NSUUID UUID] UUIDString]];
        facedetectQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    });
    return facedetectQueue;
}

@interface SLVideoBufferDetectionViewController ()
@property (nonatomic, strong) SSCamera *camera;
@property (nonatomic, strong) SLFaceLandmarkDetector *flDetector;
@property (nonatomic, strong) SSGLKView *glkView;
@property (nonatomic, assign) BOOL detectorIsBusy;
@property (nonatomic, strong) NSLock *bufferHandleLock;
@property (nonatomic, strong) UIView *focusView;
@end

@implementation SLVideoBufferDetectionViewController

#pragma mark - dealloc

- (void)dealloc {
    if (_camera) {
        [_camera clear];
        _camera = nil;
    }
    if (_flDetector) {
        [_flDetector close]; _flDetector = nil;
    }
}

#pragma mark - life cycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.camera && self.camera.isPrepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.camera && self.camera.isPrepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 停止录制并停止语音播报
    [self.camera stopRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![self.camera isRunning]) {
        [self.camera startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.title = @"视频帧关键点";
    _glkView = [[SSGLKView alloc]init];
    [self.view addSubview:_glkView];
    [self.glkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.backgroundColor = [UIColor clearColor];
    _focusView.layer.borderColor = [UIColor qmui_colorWithHexString:@"#FF4275"].CGColor;
    _focusView.layer.borderWidth = 1.0;
    _focusView.hidden = YES;
    [self.view addSubview:_focusView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.glkView addGestureRecognizer:tapGesture];
    
    _bufferHandleLock = [[NSLock alloc]init];
    [self prepareCamera];
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    _focusView.center = point;
    _focusView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
           self.focusView.hidden = YES;
        }];
    }];
    
    CGSize size = self.glkView.bounds.size;
    if (![self.camera isCameraPositionBack]) point.x = size.width - point.x;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    [self.camera focusAndExposureAtPoint:focusPoint];
    
}

- (void)setDetectorIsBusy:(BOOL)detectorIsBusy {
    [_bufferHandleLock lock];
    _detectorIsBusy = detectorIsBusy;
    [_bufferHandleLock unlock];
}

- (void)requestAccessCamera {
    AVAuthorizationStatus status = [AVCaptureDevice SSCameraAuthStatus];
    if (status == AVAuthorizationStatusAuthorized) {
        [self prepareCamera];
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice SSRequestAccessForCamera:^(BOOL granted) {
            if (granted) {
                [self prepareCamera];
            }
            else {
                QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:@"无相机访问许可，请更改隐私设置允许访问相机" preferredStyle:QMUIAlertControllerStyleAlert];
                [alertController addAction:[QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }]];
                [alertController showWithAnimated:YES];
            }
        }];
    }
}

- (void)showSDKNoAuthAlertCotroller:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)showSDKAuthResult:(NSError*)error {
    if (error && error.code == SLErrorCodeSDKVerifyFailed) {
        [self showSDKNoAuthAlertCotroller:@"SDK授权验证失败"];
        return YES;
    }
    if (error && error.code == SLErrorCodeSDKUnAuthorized) {
        [self showSDKNoAuthAlertCotroller:@"SDK未授权"];
        return YES;
    }
    if (error && error.code == SLErrorCodeSDKAuthorizationExpired) {
        [self showSDKNoAuthAlertCotroller:@"SDK授权过期"];
        return YES;
    }
    return NO;
}

- (void)prepareCamera {
    if (self.camera) {
        [self.camera startRunning];
        return;
    }
    _camera = [[SSCamera alloc]init];
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    NSError *error;
    BOOL ret = [_camera prepareCamera:position error:&error];
    if (!ret) {
        NSLog(@"--相机初始化错误--%@",error);
//        @weakify(self);
        [self showSDKNoAuthAlertCotroller:@"调用相机出错，请返回重试"];
        return;
    }
    
    if (self.camera && self.camera.isPrepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
//    [self.view.layer insertSublayer:self.camera.videoPreviewLayer atIndex:0];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    _flDetector = [[SLFaceLandmarkDetector alloc]init];
    ret = [_flDetector prepareGraphInBundle:bundle error:&error];
    if (!ret) {
        NSLog(@"--检测器模型初始化失败--%@",error);
        [self showSDKNoAuthAlertCotroller:@"检测器模型初始化失败，请返回重试"];
        return;
    }
    SLFaceLandmarkConfig *config = [[SLFaceLandmarkConfig alloc]init];
    config.rotation = SL_ROTATION_ANGLE_0;
    config.detectionMode = SLFaceDetectionModeVideoTracking;
    ret = [_flDetector openWithConfig:config error:&error];
    if (!ret) {
        
        if (![self showSDKAuthResult:error]) {
            NSLog(@"--检测器打开失败--%@",error);
            [self showSDKNoAuthAlertCotroller:@"检测器打开失败，请返回重试"];
        }
        return;
    }
    
    @weakify(self);
    [self.camera setDidOutputSampleBufferBlock:^(AVCaptureOutput *output, CMSampleBufferRef sampleBuffer, NSArray<SSFaceObject*>*faceInfoArray, AVCaptureConnection *connection) {
        @strongify(self);
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        [self detectFaceLandmarkInPixelBuffer:pixelBuffer];
    }];            
    [self.camera startRunningSynchronously];
}


- (void)detectFaceLandmarkInPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixelBuffer];
    OSType pixelType = CVPixelBufferGetPixelFormatType(pixelBuffer);
    int type = CV_8UC4;
    int code = CV_RGB2RGBA;
    switch (pixelType) {
        case kCVPixelFormatType_24RGB: {
                type = CV_8UC3;
                code = CV_RGB2RGBA;
            }
            break;
        case kCVPixelFormatType_24BGR: {
            type = CV_8UC3;
            code = CV_BGR2RGBA;
        }
        break;
        case kCVPixelFormatType_32BGRA: {
            type = CV_8UC4;
            code = CV_BGR2RGBA;
        }
        break;
        case kCVPixelFormatType_32RGBA: {
            type = CV_8UC4;
            code = -1;
        }
        break;
        default: {
            type = CV_8UC1;
            code = CV_GRAY2RGBA;
        }
            break;
    }
    
    cv::Mat inputMat;
    cv::Size size;
    if (pixelType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ||
        pixelType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
        pixelType == kCVPixelFormatType_420YpCbCr8Planar ||
        pixelType == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange ||
        pixelType == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange) {
        
        UInt8 *baseAddress = (UInt8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
        int pixelWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer,0);
        int pixelHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer,0);
        int bytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
        cv::Size size = cv::Size(pixelWidth, pixelHeight);
        inputMat = cv::Mat(size, CV_8UC1, baseAddress,bytesPerRow);
    }
    else {
        UInt8 *baseAddress = (UInt8*)CVPixelBufferGetBaseAddress(pixelBuffer);
        int pixelWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int pixelHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
        cv::Size size = cv::Size(pixelWidth, pixelHeight);
        inputMat = cv::Mat(size, type, baseAddress,bytesPerRow);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
    if (inputMat.empty()) {
        NSLog(@"--矩阵为空--");
        cv::transpose(inputMat, inputMat);
        cv::flip(inputMat, inputMat, 1);
        SSDispatchAsyncMain(^{
            [self.glkView renderCIImage:ciImage];
        });
        return;
    }
//        NSLog(@"输入线程:%@",[NSThread currentThread]);
//        NSLog(@"输入线程Symbols:%@",[NSThread callStackSymbols]);
//        usleep(100);
    
     CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
//    [NSThread sleepForTimeInterval:3.13];
    [self.flDetector detectWithVideoBuffer:pixelBuffer result:^(SLFaceDetectionResult * _Nullable result, NSError * _Nullable error) {
        //在这写入要计算时间的代码
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"单帧人脸识别时间 %f ms", linkTime *1000.0);
        
//            NSLog(@"输出线程:%@",[NSThread currentThread]);
//            NSLog(@"输出线程Symbols:%@",[NSThread callStackSymbols]);
        if (error) {
            // 如果未授权，相机运行可能导致多次回调，需要注意重复弹框
            if (![self showSDKAuthResult:error]) {
                NSLog(@"--关键点检测错误--%@",error);
            }
            SSDispatchAsyncMain(^{
                [self.glkView renderCIImage:ciImage];
            });
            return;
        }
//            NSLog(@"--检测到关键点--[%@]%@",@([NSThread isMainThread]),result);
        CFAbsoluteTime drawTime =CFAbsoluteTimeGetCurrent();
        for (SLFace *face in result.faces) {
            
            CGRect rect = face.faceRect;
            CGFloat x = rect.origin.x;  CGFloat y = rect.origin.y;
            CGFloat width = rect.size.width;  CGFloat height = rect.size.height;
            cv::Point cvPoint1(x , y); cv::Point cvPoint2(x+width, y+height);
            cv::rectangle(inputMat, cvPoint1, cvPoint2, cv::Scalar(255,255,255,255),3);
            
            for (NSValue *value in face.landmarks) {
                CGPoint point = [value CGPointValue];
                cv::Point cvPoint(point.x, point.y);
                cv::circle(inputMat, cvPoint, 2, cv::Scalar(255,255,255,255),3);
            }
        }
        
        UIImage *image;
        if (code != -1) {
            cv::Mat rgbaMat;
            cv::cvtColor(inputMat, rgbaMat, code);
//                cv::transpose(rgbaMat, rgbaMat);
//                cv::flip(rgbaMat, rgbaMat, 1);
            image =  MatToUIImage(rgbaMat);
        }
        else {
//                cv::transpose(inputMat, inputMat);
//                cv::flip(inputMat, inputMat, 1);
            image =  MatToUIImage(inputMat);
        }
        CIImage *ciImage = [[CIImage alloc]initWithImage:image];
        linkTime = (CFAbsoluteTimeGetCurrent() - drawTime);
        NSLog(@"人脸框和关键点绘制时间 %f ms", linkTime *1000.0);
        SSDispatchAsyncMain(^{
            CFAbsoluteTime renderTime =CFAbsoluteTimeGetCurrent();
            [self.glkView renderCIImage:ciImage];
            CFAbsoluteTime renderlinkTime = (CFAbsoluteTimeGetCurrent() - renderTime);
            NSLog(@"人脸框和关键点渲染 %f ms", renderlinkTime *1000.0);
        });
    }];
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image{
    BOOL hasAlpha = NO;
    CGImageRef imageRef = image.CGImage;
    CGImageAlphaInfo alphaInfo = (CGImageAlphaInfo)(CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask);
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    cv::Mat cvMat;
    CGBitmapInfo bitmapInfo;
    CGFloat cols = CGImageGetWidth(imageRef);
    CGFloat rows = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    if (numberOfComponents == 1){// check whether the UIImage is greyscale already
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    else {
        cvMat = cv::Mat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
        bitmapInfo = kCGBitmapByteOrder32Host;
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo                  // Bitmap info flags
                                                    );
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);     // decode
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat &)cvMat{
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    size_t elemsize = cvMat.elemSize();
    if (elemsize == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= (elemsize == 4) ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNone;
    }
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:elemsize * cvMat.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                 // width
                                        cvMat.rows,                 // height
                                        8,                          // bits per component
                                        8 * cvMat.elemSize(),       // bits per pixel
                                        cvMat.step[0],              // bytesPerRow
                                        colorSpace,                 // colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   // CGDataProviderRef
                                        NULL,                       // decode
                                        false,                      // should interpolate
                                        kCGRenderingIntentDefault   // intent
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
@end
