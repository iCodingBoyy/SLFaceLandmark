//
//  SSFaceObject.m
//  CBeauty
//
//  Created by 远征 马 on 2020/6/5.
//  Copyright © 2020 wff. All rights reserved.
//

#import "SSFaceObject.h"
#import <YYKit/YYKit.h>

@implementation SSFaceObject
- (BOOL)isStandardFace {
    if (!self.hasRollAngle && !self.hasYawAngle) {
        return YES;
    }
    if (self.hasRollAngle && self.hasYawAngle) {
        return (self.yawAngle <= 0 && self.rollAngle == 270);
    }
    if (self.hasRollAngle) {
        return (self.rollAngle == 270);
    }
    if (self.hasYawAngle) {
        return (self.yawAngle <= 0);
    }
    return NO;
}

- (NSString*)description {
    return [self modelDescription];
}
@end
