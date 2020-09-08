//
//  UIDevice+SSDevice.m
//  CBeauty
//
//  Created by 远征 马 on 2020/5/26.
//  Copyright © 2020 wff. All rights reserved.
//

#import "UIDevice+SSDevice.h"
#import <sys/utsname.h>

@implementation UIDevice (SSDevice)
+ (BOOL)SSIsValidPiexlesInDevice {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if ( [platform isEqualToString:@"i386"] ) {
        return NO;//@"iPhone Simulator";
    }
    if ( [platform isEqualToString:@"x86_64"] ) {
        return NO;//@"iPhone Simulator";
    }
    
    NSUInteger location = [platform rangeOfString:@","].location;
    if ( location < 6 ) {
        return NO;
    }
    NSInteger version = [[platform substringWithRange:NSMakeRange(6, location-6)] integerValue];
    if ( [platform containsString:@"iPhone"] && version < 8 ) {
        return NO;
    }
    if ( [platform isEqualToString:@"iPhone8,4"] )  {
        return NO;
    }
    return YES;
}
@end
