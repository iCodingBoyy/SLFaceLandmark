//
//  SSFaceObject.h
//  CBeauty
//
//  Created by 远征 马 on 2020/6/5.
//  Copyright © 2020 wff. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSFaceObject : NSObject
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) NSInteger faceID;
@property (nonatomic, assign) BOOL hasRollAngle;
@property (nonatomic, assign) CGFloat rollAngle;
@property (nonatomic, assign) BOOL hasYawAngle;
@property (nonatomic, assign) CGFloat yawAngle;
- (BOOL)isStandardFace;
@end

NS_ASSUME_NONNULL_END
