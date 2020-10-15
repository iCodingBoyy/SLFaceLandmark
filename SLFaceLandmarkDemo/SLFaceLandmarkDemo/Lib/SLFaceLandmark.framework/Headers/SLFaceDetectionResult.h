//
//  SLFaceLandmarks.h
//  HETFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/19.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLFace : NSObject
/// 使用时从NSValue提取CGPoint
@property (nonatomic, strong) NSArray <NSValue*>*landmarks;
@property (nonatomic, assign) CGRect faceRect;
@end

@interface SLFaceDetectionResult : NSObject
@property (nonatomic, assign) NSInteger faceNum;
@property (nonatomic, strong) NSArray <SLFace*>*faces;
@end

NS_ASSUME_NONNULL_END
