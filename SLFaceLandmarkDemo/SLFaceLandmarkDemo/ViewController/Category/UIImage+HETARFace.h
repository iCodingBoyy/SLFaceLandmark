//
//  UIImage+HETARFace.h
//  HETARFaceEngine
//
//  Created by 远征 马 on 2020/6/30.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>



 FOUNDATION_EXPORT Byte *HARFGetImagePixelData(UIImage *image);


@interface UIImage (HETARFace)

+ (UIImage*)arfaceScaledImageWithName:(NSString*)name;
+ (UIImage*)arfaceScaledImageWithName:(NSString*)name color:(UIColor*)color;
- (UIImage*)fixedOrientation;
+ (UIImage*)convertBitmapRGBA8ToUIImage:(void *) buffer size:(CGSize)size;
@end

