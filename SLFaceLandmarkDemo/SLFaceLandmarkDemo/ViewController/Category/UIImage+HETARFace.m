//
//  UIImage+HETARFace.m
//  HETARFaceEngine
//
//  Created by 远征 马 on 2020/6/30.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "UIImage+HETARFace.h"
#import <YYKit/YYKit.h>
#import <QMUIKit/QMUIKit.h>

CGContextRef CreateRGBABitmapContext (CGImageRef cgImage) {
    size_t pixelsWidth = CGImageGetWidth(cgImage);
    size_t pixelsHight = CGImageGetHeight(cgImage);
    size_t bitmapBytesPerRow = (pixelsWidth * 4);
    size_t bitmapByteCount = (bitmapBytesPerRow * pixelsHight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)  {
        fprintf(stderr, "Error allocating color space");
        return NULL;
    }
    // allocate the bitmap & create context
    void *bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) {
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    CGContextRef context = CGBitmapContextCreate (bitmapData, pixelsWidth, pixelsHight,8,
    bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
     }
    CGColorSpaceRelease( colorSpace );
     return context;
}

Byte *HARFGetImagePixelData(UIImage *image) {
    if (!image) return NULL;
    CGImageRef cgImage = image.CGImage;
    CGSize size = [image size];
    CGContextRef cgctx = CreateRGBABitmapContext(cgImage);
    if (cgctx == NULL)
    return NULL;
     
    CGRect rect = {{0,0},{size.width, size.height}};
    CGContextDrawImage(cgctx, rect, cgImage);
    Byte *byte = CGBitmapContextGetData (cgctx);
    CGContextRelease(cgctx);
    return byte;
}

@implementation UIImage (HETARFace)
+ (UIImage*)arfaceScaledImageWithName:(NSString*)name {
    if (!name) return nil;
    UIImage *image = [UIImage imageNamed:name];
    if (!image) return nil;
    
    CGSize size = image.size;
    CGSize scaledSize = CGSizeMake(size.width*0.5, size.height*0.5);
    return [image imageByResizeToSize:scaledSize];
}

+ (UIImage*)arfaceScaledImageWithName:(NSString*)name color:(UIColor*)color {
    if (!name) return nil;
    UIImage *image = [[UIImage imageNamed:name]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (!image) return nil;
    image = [image qmui_imageWithBlendColor:color];
    CGSize size = image.size;
    CGSize scaledSize = CGSizeMake(size.width*0.5, size.height*0.5);
    return [image imageByResizeToSize:scaledSize];
}


+ (UIImage*)convertBitmapRGBA8ToUIImage:(void *) buffer size:(CGSize)size {
    int width = (int)size.width;
    int height = (int)size.height;
    size_t bufferLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    if(colorSpaceRef == NULL){
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,    // data provider
                                    NULL,        // decode
                                    YES,            // should interpolate
                                    renderingIntent);
    
    uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef,
                                                 bitmapInfo);
    
    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
    }
    UIImage *image = nil;
    if(context) {
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    if(pixels) {
        free(pixels);
    }
    return image;
}

- (UIImage*)fixedOrientation {
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
