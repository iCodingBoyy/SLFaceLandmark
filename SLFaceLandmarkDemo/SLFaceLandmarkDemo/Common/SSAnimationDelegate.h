//
//  SSAnimationDelegate.h
//  CBeauty
//
//  Created by 远征 马 on 2020/5/27.
//  Copyright © 2020 wff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface SSAnimationDelegate : NSObject<CAAnimationDelegate>
@property (nonatomic, copy) void (^animationDidStartBlock)(CAAnimation *anim);
@property (nonatomic, copy) void (^animationDidStopBlock) (CAAnimation *anim,BOOL flag);
@end

