//
//  JWQrCodeSystem.h
//  JWQrCodeDemo
//
//  Created by GJW on 16/8/3.
//  Copyright © 2016年 JW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface JWQrCodeSystem : NSObject
/**
 *  是否开启系统灯光
 *
 *  @param open 是否打开
 */
+ (void)boolOpenLight:(BOOL)open;


@end
