//
//  SSAnimationDelegate.m
//  CBeauty
//
//  Created by 远征 马 on 2020/5/27.
//  Copyright © 2020 wff. All rights reserved.
//

#import "SSAnimationDelegate.h"

@implementation SSAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.animationDidStartBlock){
        self.animationDidStartBlock(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.animationDidStopBlock){
        self.animationDidStopBlock(anim,flag);
    }
}
@end
