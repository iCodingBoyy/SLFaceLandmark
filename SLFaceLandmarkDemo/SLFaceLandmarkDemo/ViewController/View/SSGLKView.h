//
//  FBGLKView.h
//  HETFaceBeauty
//
//  Created by 远征 马 on 2019/12/30.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SSGLKView : GLKView
- (void)renderCIImage:(CIImage*)ciImage;
@end
