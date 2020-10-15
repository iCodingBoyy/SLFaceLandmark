//
//  SLBaseAnalyzer.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/10/9.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SLFeatureDelegate <NSObject>
@required
- (NSDictionary*)JSONObject;

@optional
- (BOOL)isEqualToFeature:(id)object;
@end

@interface SLBaseAnalyzer : NSObject

@end

NS_ASSUME_NONNULL_END
