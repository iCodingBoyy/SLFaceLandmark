//
//  SLThreePartsAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLBaseAnalyzer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLThreePart : NSObject
@property (nonatomic, assign) CGFloat length;
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, strong) NSString *result;
@end

@interface SLThreeParts : NSObject
@property (nonatomic, assign) CGFloat faceLength;
@property (nonatomic, strong) NSString *partsRatio;
@property (nonatomic, strong) SLThreePart *partOne;
@property (nonatomic, strong) SLThreePart *partTwo;
@property (nonatomic, strong) SLThreePart *partThree;
@end

@interface SLThreePartsAnalyzer : SLBaseAnalyzer
+ (SLThreeParts*)analysisInLandmarks:(nullable NSArray*)landmarks;
@end

NS_ASSUME_NONNULL_END
