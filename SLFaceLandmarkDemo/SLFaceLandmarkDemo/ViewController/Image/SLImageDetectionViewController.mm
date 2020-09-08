//
//  SLImageDetectionViewController.m
//  SLFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/20.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "SLImageDetectionViewController.h"
#import <Masonry/Masonry.h>
#import <SLFaceLandmark/SLFaceLandmarkDetector.h>
//#import "SLFaceLandmarkDetector.h"
#import "SLNavigationController.h"
#import "UIImage+HETARFace.h"

@interface SLImageDetectionViewController () <QMUIAlbumViewControllerDelegate,QMUIImagePickerViewControllerDelegate,
QMUIImagePickerPreviewViewControllerDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SLFaceLandmarkDetector *flDetector;
@end

@implementation SLImageDetectionViewController

- (void)dealloc {
    if (_flDetector) {
        [_flDetector close]; _flDetector = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.title = @"图片关键点";
    [self makeConstraints];
    [self prepareFLDetector];
}

- (void)showSDKNoAuthAlertCotroller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"SDK未授权，请前往平台授权处理" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareFLDetector {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    _flDetector = [[SLFaceLandmarkDetector alloc]init];
    NSError *error;
    BOOL ret = [_flDetector prepareGraphInBundle:bundle error:&error];
    if (!ret) {
        NSLog(@"--检测器模型初始化失败--%@",error);
        return;
    }
    SLFaceLandmarkConfig *config = [[SLFaceLandmarkConfig alloc]init];
    config.rotation = SL_ROTATION_ANGLE_0;
    config.detectionMode = SLFaceDetectionModeImage;
    ret = [_flDetector openWithConfig:config error:&error];
    if (!ret) {
        if (error.code == SLErrorCodeInvalidAuthorization) {
            [self showSDKNoAuthAlertCotroller];
        }
        else {
            NSLog(@"--检测器打开失败--%@",error);
        }
        return;
    }
    [_flDetector detectWithFaceImage:self.imageView.image result:^(SLFaceDetectionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (error.code == SLErrorCodeInvalidAuthorization) {
                [self showSDKNoAuthAlertCotroller];
            }
            else {
                NSLog(@"--关键点检测错误--%@",error);
            }
            return;
        }
        NSLog(@"--检测到关键点--%@",result);
        // 在图片上绘制关键点
        cv::Mat imageMat;
        UIImageToMat(self.imageView.image, imageMat);
        for (SLFace *face in result.faces) {
            for (NSValue *value in face.landmarks) {
                CGPoint point = [value CGPointValue];
                cv::Point cvPoint(point.x, point.y);
                cv::circle(imageMat, cvPoint, 2, cv::Scalar(255,255,255,255),5);
            }
        }
        UIImage *image =  MatToUIImage(imageMat);
        self.imageView.image = image;
    }];
}

- (void)detectFaceLandmarkFromImage:(UIImage*)image {
    [_flDetector detectWithFaceImage:image result:^(SLFaceDetectionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (error.code == SLErrorCodeInvalidAuthorization) {
                [self showSDKNoAuthAlertCotroller];
            }
            else {
                NSLog(@"--关键点检测错误--%@",error);
            }
            return;
        }
        NSLog(@"--检测到关键点--%@",result);
        // 在图片上绘制关键点
        cv::Mat imageMat;
        UIImageToMat(image, imageMat);
        for (SLFace *face in result.faces) {
            for (NSValue *value in face.landmarks) {
                CGPoint point = [value CGPointValue];
                cv::Point cvPoint(point.x, point.y);
                cv::circle(imageMat, cvPoint, 2, cv::Scalar(255,255,255,255),5);
            }
        }
        UIImage *image =  MatToUIImage(imageMat);
        self.imageView.image = image;
    }];
}

#pragma mark - constraints

- (void)makeConstraints {
    UIImage *image = [UIImage imageNamed:@"frame.jpg"];
    _imageView = [[UIImageView alloc]initWithImage:image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    
//    QMUIFillButton *button = [[QMUIFillButton alloc]init];
//    button.fillColor = [UIColor qmui_colorWithHexString:@"#FF4275"];
//    button.titleTextColor = [UIColor whiteColor];
//    [button setTitle:@"更换图像" forState:UIControlStateNormal];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(clickToPickPhoto)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithTitle:@"相机" style:UIBarButtonItemStylePlain target:self action:@selector(clickToShowCamera)];
    self.navigationItem.rightBarButtonItems = @[item1,item2];
}

- (void)clickToShowCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
    image = [image qmui_imageResizedInLimitedSize:CGSizeMake(2000, 2000) resizingMode:QMUIImageResizingModeScaleAspectFit];
    image = [image fixedOrientation];
    [self detectFaceLandmarkFromImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)clickToPickPhoto {
    QMUIAlbumViewController *albumViewController = [[QMUIAlbumViewController alloc] init];
    albumViewController.albumViewControllerDelegate = self;
    albumViewController.contentType = QMUIAlbumContentTypeOnlyPhoto;
    albumViewController.title = @"选取人脸照片";
    [albumViewController pickLastAlbumGroupDirectlyIfCan];
    
    SLNavigationController *navigationController = [[SLNavigationController alloc]initWithRootViewController:albumViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}


#pragma mark - QMUIAlbumViewControllerDelegate

- (QMUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(QMUIAlbumViewController *)albumViewController {
    
    QMUIImagePickerViewController *imagePickerViewController = [[QMUIImagePickerViewController alloc] init];
    imagePickerViewController.imagePickerViewControllerDelegate = self;
    imagePickerViewController.maximumSelectImageCount = 1;
    imagePickerViewController.allowsMultipleSelection = NO;
    return imagePickerViewController;
    
}

- (void)albumViewControllerDidCancel:(QMUIAlbumViewController *)albumViewController {
    
}

#pragma mark - <QMUIImagePickerViewControllerDelegate>

- (void)imagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController didSelectImageWithImagesAsset:(QMUIAsset *)imageAsset afterImagePickerPreviewViewControllerUpdate:(QMUIImagePickerPreviewViewController *)imagePickerPreviewViewController {
    UIImage *orginImage = [imageAsset originImage];
    orginImage = [orginImage qmui_imageResizedInLimitedSize:CGSizeMake(2000, 2000) resizingMode:QMUIImageResizingModeScaleAspectFit];
    orginImage = [orginImage fixedOrientation];
    [self detectFaceLandmarkFromImage:orginImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerViewControllerDidCancel:(QMUIImagePickerViewController *)imagePickerViewController {
    
}


@end
