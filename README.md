#SLFaceLandmark

[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](https://clife-devops.coding.net/p/AR_makeup/d/SLFaceLandmarkPublic/git/tree/master/ios/README.md?tab=file)&nbsp;
[![Platform](https://img.shields.io/badge/platform-iOS%2010.0-orange.svg)](https://clife-devops.coding.net/p/AR_makeup/d/SLFaceLandmarkPublic/git/tree/master/ios/README.md?tab=file)&nbsp;
[![Build Status](https://img.shields.io/badge/build-passing-red.svg)](https://clife-devops.coding.net/p/AR_makeup/d/SLFaceLandmarkPublic/git/tree/master/ios/README.md?tab=file)&nbsp;


### 一、简介

`SLFaceLandmark` 是人脸关键点检测动态库，支持静态图片和动态视频帧人脸关键点检测。

### 二、预览
下图静态图片人脸关键点展示，动态视频帧可运行demo看效果
[静态人脸图片关键点](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a876a351ca4b4aafadf6d4a85e8d437f~tplv-k3u1fbpfcp-zoom-1.image)


### 三、快速集成
#### 3.1、`SLFaceLandmark` 集成非常简单，将`framework`包拖到你的`Xcode`工程，将`Embed`设置为`Embed & Sign`。

![关键点库集成](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1f2ad87d000c4376b2badff128d76119~tplv-k3u1fbpfcp-zoom-1.image)

#### 3.2、前往[OpenCV](https://opencv.org/releases/)下载`opencv2.framework`，选择3.4.x版本即可。
#### 3.3、集成`OpenSSL`,如果使用`Cocoapods`管理，可使用`pod`搜索对应的`OpenSSL`库：
![OpenSSL库](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/06bce5e685994563840863f4116a0ee6~tplv-k3u1fbpfcp-zoom-1.image)

我一般会安装如下版本：
```
pod 'OpenSSL-Universal', '~> 1.0.2.20'
```
#### 3.4、框架内部添加了分类文件，注意设置`-ObjC`标识

### 四、SDK授权
调用`SLFaceLandmark.framework`动态库前，你需要联系`HET`相关人员获取注册应用的`AppId`和`AppSecret`。
具体可咨询相关客服。
一切准备妥当后，在应用中优先申请注册获取授权信息。

```Objective-C
    // 优先导入头文件
    #import <SLFaceLandmark/SLFaceLandmark.h>
    
    // C风格注册获取授权
    SLFaceLandmarkRegister(@"31586", @"aa9021a26dad477cbe0ce446555adb9c");
    // OC风格注册获取授权
    [SLFaceLandmark registerWithAppId:@"31586" appSecret:@"aa9021a26dad477cbe0ce446555adb9c"];
```


### 五、接入指南
在调用相关接口前请先下载`SDK`，查看相关头文件，熟悉调用接口。
数据帧、静态图片、视频帧检测不能混合调用，都是相互独立的，每一项检测都需要单独初始化检测器，都需要执行 `模型初始化、开启检测器、人脸和关键点检测、关闭检测器`相关流程。
使用前优先导入头文件：
```Objective-C
    #import <SLFaceLandmark/SLFaceLandmarkDetector.h>   
```

#### 5.1、模型加载初始化
`SLFaceLandmark`是基于模型调用进行人脸检测，使用前需要优先载入模型数据：
```Objective-C
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    SLFaceLandmarkDetector *flDetector = [[SLFaceLandmarkDetector alloc]init];
    ret = [flDetector prepareGraphInBundle:bundle error:&error];
    if (!ret) {
        NSLog(@"--检测器模型初始化失败--%@",error);
        return;
    }
```
#### 5.2、开启检测线程
开启检测线程,开启检测前需要做相关的配置，如设置照片的方向、检测模式等，静态图片竖直方向可设置0度检测，如果照片是横向的需要进行翻转，视频帧也是一样，请注意相机`videoConnection`的方向。
@see `SLFaceLandmarkConfig`
```Objective-C
    SLFaceLandmarkConfig *config = [[SLFaceLandmarkConfig alloc]init];
    config.rotation = SL_ROTATION_ANGLE_0;
    config.detectionMode = SLFaceDetectionModeVideoTracking;
    ret = [_flDetector openWithConfig:config error:&error];
    if (!ret) {
        if (error.code == SLErrorCodeInvalidAuthorization) {
            NSLog(@"SDK未授权，请前往平台授权处理");
        }
        else {
            NSLog(@"--检测器打开失败--%@",error);
        }
    }
```

#### 5.3、调用检测接口
当检测线程正常开启后，可调用接口进行人脸关键点检测，支持数据、人脸图片、视频帧`buffer`检测
##### 5.3.1、数据帧检测
为防止数据格式不兼容造成问题，此接口最好把人脸图像`SL_DATA_FRAME`结构体数据转换为`RGBA`格式输入，其他格式需要注意下图像排列问题。
```Objective-C
    // 初始化数据帧结构体
    SL_DATA_FRAME sl_data_frame;
    sl_data_frame.width = (int32_t)frameWidth;
    sl_data_frame.height = (int32_t)frameHeight;
    sl_data_frame.rotation_angle = SL_ROTATION_ANGLE_0;
    sl_data_frame.image_format = SL_IMAGE_FORMAT_RGBA;
    sl_data_frame.data = (uint8_t*)imageBytes;
    sl_data_frame.data_length = (int32_t)byteSize;

    [_flDetector detectWithDataFrame:sl_data_frame result:^(SLFaceDetectionResult * _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            if (error.code == SLErrorCodeInvalidAuthorization) {
                NSLog(@"SDK未授权，请前往平台授权处理");
            }
            else {
                NSLog(@"--关键点检测错误--%@",error);
            }
            return;
        }
        // 关键点信息做相关处理
    }];
```
##### 5.3.2、静态人脸图片检测
静态人脸图片检测非常简单，传入`Image`对象即可:
```Objective-C
    [_flDetector detectWithFaceImage:self.imageView.image result:^(SLFaceDetectionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (error.code == SLErrorCodeInvalidAuthorization) {
                NSLog(@"SDK未授权，请前往平台授权处理");
            }
            else {
                NSLog(@"--关键点检测错误--%@",error);
            }
            return;
        }
    }];
```
##### 5.3.3、视频帧人脸检测
视频帧人脸检测需要注意相机`videoConnection`设置的方向，传入的`config`的`rotation`旋转方向需要与相机视频人脸方向一致。
```Objective-C
     CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    [_flDetector detectWithVideoBuffer:pixelBuffer result:^(SLFaceDetectionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (error.code == SLErrorCodeInvalidAuthorization) {
                NSLog(@"SDK未授权，请前往平台授权处理");
            }
            else {
                NSLog(@"--关键点检测错误--%@",error);
            }
            return;
        }
    }];
```
视频帧仅支持有限的格式，使用前需要注意设置`Camera`格式

##### 5.3.4、关闭检测器
使用完毕退出当前页面时需要释放资源，调用`close`即可
```Objective-C
   // 关闭检测器，释放资源 
   [_flDetector close];
```

