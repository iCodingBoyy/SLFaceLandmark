//
//  FBGLKView.m
//  HETFaceBeauty
//
//  Created by 远征 马 on 2019/12/30.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "SSGLKView.h"
#import <CoreImage/CoreImage.h>

@interface SSGLKView ()
@property (nonatomic, strong) CIImage *displayImage;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, assign) CGAffineTransform scale;
@property (nonatomic, assign) CGRect imageDrawRect;
@end


@implementation SSGLKView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

+ (EAGLContext*)sharedContext {
    static EAGLContext *sharedContext = nil;
    if (!sharedContext){
        sharedContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    return sharedContext;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self){
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    EAGLContext *sharedContext = [[self class]sharedContext];
    self.context = sharedContext;
    [EAGLContext setCurrentContext:sharedContext];
    
//    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.enableSetNeedsDisplay = YES;
    
//    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3 sharegroup:[[self class] sharedContext].sharegroup];
//    [EAGLContext setCurrentContext:self.context];
    self.ciContext = [CIContext contextWithEAGLContext:sharedContext options:nil];
    self.scale = CGAffineTransformMakeScale(self.contentScaleFactor, self.contentScaleFactor);
}

- (void)renderImage:(UIImage*)matImage
{
    if (!matImage) {
        return;
    }
    self.displayImage = [CIImage imageWithCGImage:matImage.CGImage];
    [self setNeedsDisplay];
}

- (void)renderCIImage:(CIImage*)ciImage
{
    if (!ciImage) {
        return;
    }
    self.displayImage = ciImage;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    NSLog(@"---rect---%@",NSStringFromCGRect(rect));
    if(CGRectEqualToRect(self.imageDrawRect, CGRectZero)){
        self.imageDrawRect =  CGRectApplyAffineTransform(self.bounds, self.scale);
    }
    if (self.displayImage){
        [self.ciContext drawImage:self.displayImage inRect:self.imageDrawRect fromRect:[self.displayImage extent]];
    }
}

@end
