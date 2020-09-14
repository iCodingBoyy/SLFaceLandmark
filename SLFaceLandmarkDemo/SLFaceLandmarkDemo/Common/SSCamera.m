//
//  SSCamera.m
//  SSSkinAnalysis
//
//  Created by 远征 马 on 2020/5/13.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SSCamera.h"
#import "AVCaptureDevice+SSDevice.h"
#import "UIDevice+SSDevice.h"
#import "SSAnimationDelegate.h"

dispatch_queue_t SSVideoOutputQueue(void)
{
    static dispatch_queue_t videoOutputQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [NSString stringWithFormat:@"com.SkinAnalysis.videoDataOutputQueue-%@", [[NSUUID UUID] UUIDString]];
        videoOutputQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    });
    return videoOutputQueue;
}

dispatch_queue_t SSSkinAnalysisSerialQueue(void)
{
    static dispatch_queue_t skinAnalysisSerialQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [NSString stringWithFormat:@"com.skin.anslysis.queue-%@", [[NSUUID UUID] UUIDString]];
        skinAnalysisSerialQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    });
    return skinAnalysisSerialQueue;
}

static NSString *SSCaptureDeviceErrorDomain = @"SSCaptureDeviceErrorDomain";


@interface SSCamera () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
//@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;
@property (nonatomic, strong) AVCaptureDeviceInput *frontDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *backDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaout;
@property (nonatomic, strong) NSArray *metadataObjects;
@end


@implementation SSCamera
@synthesize videoPreviewLayer = _videoPreviewLayer;
@synthesize isPrepared = _isPrepared;


- (BOOL)prepareCamera:(AVCaptureDevicePosition)position error:(NSError**)error {
    _isPrepared = NO;
    if (position != AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    }
    _captureDevice = [AVCaptureDevice SSGetCaptureDeviceWithPosition:position];
    if (!_captureDevice) {
        if (position == AVCaptureDevicePositionBack) {
            position = AVCaptureDevicePositionFront;
        }
        _captureDevice = [AVCaptureDevice SSGetCaptureDeviceWithPosition:position];
    }
    if (!_captureDevice) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"获取capture device 出错"};
        *error = [NSError errorWithDomain:SSCaptureDeviceErrorDomain
                                     code:8000
                                 userInfo:userInfo];
        return NO;
    }
    NSError *aError;
    AVCaptureDeviceInput *deviceInput = nil;
    deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:_captureDevice error:&aError];
    if (!deviceInput) {
        NSLog(@"--AVCaptureDeviceInput 初始化错误----%@",aError);
        *error = aError;
        return NO;
    }
    if (_captureDevice.position == AVCaptureDevicePositionBack) {
        _backDeviceInput = deviceInput;
    }
    else {
        _frontDeviceInput = deviceInput;
    }
    [self.captureSession beginConfiguration];
    for (AVCaptureInput *oldInput in self.captureSession.inputs) {
        [self.captureSession removeInput:oldInput];
    }
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }
    else {
        NSLog(@"---无法添加输入--%@",deviceInput);
        [self.captureSession commitConfiguration];
        return NO;
    }
    if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession addOutput:self.captureVideoDataOutput];
    }
    else {
        [self.captureSession commitConfiguration];
        return NO;
    }
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    else {
        [self.captureSession commitConfiguration];
        return NO;
    }
    // 设置照片输出 AVCaptureSessionPresetHigh AVCaptureSessionPreset1280x720 AVCaptureSessionPreset1920x1080 AVCaptureSessionPresetPhoto
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else {
        [self.captureSession commitConfiguration];
        return NO;
    }
//    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
//        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
//    }
    if ([self.captureSession canAddOutput:self.metaout]) {
        [self.captureSession addOutput:self.metaout];
    }
    else {
        [self.captureSession commitConfiguration];
        return NO;
    }
    float rate = _captureDevice.position == 1 ? 20 : 30;

    if ([_captureDevice respondsToSelector:@selector(activeVideoMinFrameDuration)]) {
        [_captureDevice lockForConfiguration:nil];
        _captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, rate);
        _captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, rate);
        [_captureDevice unlockForConfiguration];
    }
    else {
        AVCaptureConnection *conn = [[_captureSession.outputs lastObject] connectionWithMediaType:AVMediaTypeVideo];
        if (conn.supportsVideoMinFrameDuration)
            conn.videoMinFrameDuration = CMTimeMake(1,rate);
        if (conn.supportsVideoMaxFrameDuration)
            conn.videoMaxFrameDuration = CMTimeMake(1,rate);
    }
    [self refreshVideoConnection];
    [_metaout setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    _metaout.rectOfInterest = [UIScreen mainScreen].bounds;
    [self.captureSession commitConfiguration];
    _isPrepared = YES;
    return YES;
}



#pragma mark - take Photos

- (BOOL)isCapturingStillImage {
    return self.captureStillImageOutput.isCapturingStillImage;
}

- (AVCaptureConnection*)captureStillImageConnection {
    AVCaptureConnection *captureConnection = nil;
    for (AVCaptureConnection *connection in self.captureStillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual: AVMediaTypeVideo]) {
                captureConnection = connection;
                if (captureConnection.supportsVideoMirroring) {
                    BOOL isVideoMirrored = ([self getCameraPosition] == AVCaptureDevicePositionFront);
                    captureConnection.videoMirrored = isVideoMirrored;
                    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
                }
                if ([captureConnection isVideoOrientationSupported]) {
                    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
                    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)curDeviceOrientation;
                    if ( curDeviceOrientation == UIDeviceOrientationLandscapeLeft ) {
                        videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    }
                    else if ( curDeviceOrientation == UIDeviceOrientationLandscapeRight ) {
                        videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    }
                    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
                    captureConnection.videoScaleAndCropFactor = 1.0;
                }
                break;
            }
        }
    }
    return captureConnection;
}

#pragma mark - run

- (BOOL)isRunning {
    return self.captureSession.isRunning;
}

- (void)startRunningSynchronously {
    dispatch_sync(SSSkinAnalysisSerialQueue(), ^{
        [self.captureSession startRunning];
    });
}

- (void)startRunning {
    dispatch_async(SSSkinAnalysisSerialQueue(), ^{
        [self.captureSession startRunning];
        [self focusAndExposureAtPoint:CGPointMake(0.5, 0.5)];
    });
}

- (void)stopRunning {
    dispatch_async(SSSkinAnalysisSerialQueue(), ^{
        if (self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection != self.captureConnection) {
        NSLog(@"---不正确的video连接--");
        return;
    }
    if (self.captureStillImageOutput.isCapturingStillImage) {
        NSLog(@"---正在捕获静态照片--");
        return;
    }
    NSMutableArray *faceInfoArray = [NSMutableArray arrayWithCapacity:0];
    @autoreleasepool {
        for (AVMetadataFaceObject *faceobject in self.metadataObjects) {
             AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:faceobject connection:connection];
             SSFaceObject *faceObj = [[SSFaceObject alloc]init];
             faceObj.bounds = face.bounds;
             faceObj.faceID = faceobject.faceID;
             if (faceobject.hasYawAngle) {
                 faceObj.hasYawAngle = faceobject.hasYawAngle;
                 faceObj.yawAngle = faceobject.yawAngle;
             }
             if (faceobject.hasRollAngle) {
                 faceObj.hasRollAngle = faceobject.hasRollAngle;
                 faceObj.rollAngle = faceobject.rollAngle;
             }
             [faceInfoArray addObject:faceObj];
         }
        self.metadataObjects = nil;
    }
    if (_didOutputSampleBufferBlock) {
        _didOutputSampleBufferBlock(output, sampleBuffer, faceInfoArray, connection);
    }
}

#pragma mark - 对焦与曝光

- (void)focusAndExposureAtPoint:(CGPoint)focusPoint {
    NSError *error;
    if ([self.captureDevice lockForConfiguration:&error]) {
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([self.captureDevice isFocusPointOfInterestSupported]) {
                [self.captureDevice setFocusPointOfInterest:focusPoint];
            }
        }
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            if ([self.captureDevice isExposurePointOfInterestSupported]) {
                [self.captureDevice setExposurePointOfInterest:focusPoint];
            }
            [self.captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [self.captureDevice unlockForConfiguration];
    }
    else {
        NSLog(@"--lockForConfiguration---%@",error);
    }
}

#pragma mark - clear

- (void)clear {
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
//    _captureDeviceInput = nil;
    _captureStillImageOutput = nil;
    _captureVideoDataOutput = nil;
    _captureConnection = nil;
    _frontDeviceInput = nil;
    _backDeviceInput = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - Setter /Getter

- (void)refreshVideoConnection {
        
    _captureConnection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (_captureConnection.supportsVideoMirroring) {
        BOOL isVideoMirrored = ([self getCameraPosition] == AVCaptureDevicePositionFront);
        _captureConnection.videoMirrored = isVideoMirrored;
    }
    if ([_captureConnection isVideoOrientationSupported]) {
        
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)curDeviceOrientation;
        if ( curDeviceOrientation == UIDeviceOrientationLandscapeLeft ) {
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else if ( curDeviceOrientation == UIDeviceOrientationLandscapeRight ) {
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        _captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        _captureConnection.videoScaleAndCropFactor = 1.0;
    }
}

- (BOOL)isCameraPositionBack {
   return ([self getCameraPosition] == AVCaptureDevicePositionBack);
}

- (AVCaptureDevicePosition)getCameraPosition {
    if (self.captureDevice) {
        return self.captureDevice.position;
    }
    return AVCaptureDevicePositionUnspecified;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)position result:(void(^)(AVCaptureDevicePosition position))retHandler {
    if (position == AVCaptureDevicePositionUnspecified) {
        @throw [NSException exceptionWithName:@"SkinAnalysis" reason:@"请设置back或者Front Camera参数，否则影响camera运行" userInfo:nil];
        return ;
    }
    if (position == [self getCameraPosition]) {
        if (retHandler) {
             retHandler(position);
        }
        return ;
    }
    NSUInteger cameraCout = [AVCaptureDevice SSGetCameraCount];
    if (cameraCout <= 1) {
        if (retHandler) {
             retHandler([self getCameraPosition]);
        }
        return;
    }
    AVCaptureDeviceInput *newInput = nil;
    AVCaptureDeviceInput *oldInput = nil;
    if (position == AVCaptureDevicePositionBack) {
        newInput = self.backDeviceInput;
        oldInput = self.frontDeviceInput;
    }
    else {
        newInput = self.frontDeviceInput;
        oldInput = self.backDeviceInput;
    }
    if (!newInput || !oldInput) {
        if (retHandler) {
             retHandler([self getCameraPosition]);
        }
        return;
    }
    [self playFlipAnimation:^{
        
    }];
    dispatch_async(SSSkinAnalysisSerialQueue(), ^{
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:oldInput];
        if ([self.captureSession canAddInput:newInput]) {
            [self.captureSession addInput:newInput];
            // 切换到新的device
            self.captureDevice = newInput.device;
            [self refreshVideoConnection];
        }
        else if ([self.captureSession canAddInput:oldInput]) {
            [self.captureSession addInput:oldInput];
        }
        [self.captureSession commitConfiguration];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (retHandler) {
                 retHandler([self getCameraPosition]);
            }
        });
    });
}

- (void)playFlipAnimation:(void(^)(void))retHandler {
    [self.videoPreviewLayer removeAllAnimations];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.35f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.fillMode = kCAFillModeForwards;
    animation.type = @"OglFlip";
    AVCaptureDevicePosition position = [self getCameraPosition];
    if (position == AVCaptureDevicePositionBack) {
        animation.subtype = kCATransitionFromRight;
    }
    else {
        animation.subtype = kCATransitionFromLeft;
    }
    SSAnimationDelegate *delegate = [[SSAnimationDelegate alloc]init];
    [delegate setAnimationDidStopBlock:^(CAAnimation *anim, BOOL flag) {
        if (retHandler) {
            retHandler();
        }
    }];
    animation.delegate = delegate;
    [self.videoPreviewLayer addAnimation:animation forKey:nil];
}

- (void)setVideoSettings:(NSDictionary<NSString *, id>*)videoSettings {
    [self.captureSession beginConfiguration];
    NSArray *types = [self.captureVideoDataOutput availableVideoCVPixelFormatTypes];
    if ([types containsObject:[videoSettings.allValues firstObject]]) {
        [self.captureVideoDataOutput setVideoSettings:videoSettings];
    }
    else {
        NSLog(@"--不支持的视频格式--");
        @throw [NSException exceptionWithName:@"SSCameraException" reason:@"不支持的视频格式" userInfo:nil];
    }
    [self.captureSession commitConfiguration];
}

- (BOOL)setSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    
    BOOL ret = NO;
    [self.captureSession beginConfiguration];
    if ([self.captureSession canSetSessionPreset:sessionPreset]) {
        [self.captureSession setSessionPreset:sessionPreset];
        ret = YES;
    }
    [self.captureSession commitConfiguration];
    return ret;
}

#pragma mark - layz loading

- (AVCaptureVideoPreviewLayer*)videoPreviewLayer
{
    if (_videoPreviewLayer) {
        return _videoPreviewLayer;
    }
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    return _videoPreviewLayer;
}

- (AVCaptureSession*)captureSession
{
    if (_captureSession) {
        return _captureSession;
    }
    _captureSession = [[AVCaptureSession alloc]init];
    return _captureSession;
}

API_DEPRECATED_BEGIN("Use AVCapturePhotoOutput instead.", macos(10.7, 10.15), ios(4.0, 10.0))
- (AVCaptureStillImageOutput*)captureStillImageOutput
{
    if (_captureStillImageOutput) {
        return _captureStillImageOutput;
    }
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _captureStillImageOutput.highResolutionStillImageOutputEnabled = YES;
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];
    return _captureStillImageOutput;
}
API_DEPRECATED_END


#define __OUTPUT_BGRA__
                   
- (AVCaptureVideoDataOutput*)captureVideoDataOutput
{
    if (_captureVideoDataOutput) {
        return _captureVideoDataOutput;
    }
    _captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
//    dispatch_queue_t queue = dispatch_queue_create("com.SkinAnalysis.videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_captureVideoDataOutput setSampleBufferDelegate:self queue:SSVideoOutputQueue()];
//    kCVPixelFormatType_32BGRA kCVPixelFormatType_24BGR
#ifdef __OUTPUT_BGRA__
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
#else
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
#endif
//    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
//    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
//    NSDictionary *settings = @{key:value};
    NSArray *types = [_captureVideoDataOutput availableVideoCVPixelFormatTypes];
    if ([types containsObject:[settings.allValues firstObject]]) {
        [_captureVideoDataOutput setVideoSettings:settings];
    }
    else {
        NSLog(@"--不支持的视频格式--");
    }
    return _captureVideoDataOutput;
}

- (AVCaptureMetadataOutput*)metaout
{
    if (_metaout) {
        return _metaout;
    }
    _metaout = [[AVCaptureMetadataOutput alloc] init];
    [_metaout setMetadataObjectsDelegate:self queue:SSVideoOutputQueue()];
    return _metaout;
}


- (AVCaptureDeviceInput*)frontDeviceInput
{
    if (_frontDeviceInput) {
        return _frontDeviceInput;
    }
    NSError *error;
    _frontDeviceInput = [AVCaptureDevice SSGetCaptureDeviceInputWithPosition:AVCaptureDevicePositionFront error:&error];
    if (!_frontDeviceInput && error) {
        NSLog(@"---error---%@",error);
    }
    return _frontDeviceInput;
}

- (AVCaptureDeviceInput*)backDeviceInput
{
    if (_backDeviceInput) {
        return _backDeviceInput;
    }
    NSError *error;
    _backDeviceInput = [AVCaptureDevice SSGetCaptureDeviceInputWithPosition:AVCaptureDevicePositionBack error:&error];
    if (!_backDeviceInput && error) {
        NSLog(@"---error---%@",error);
    }
    return _backDeviceInput;
}
@end
