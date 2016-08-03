//
//  JWQrCodeSystem.m
//  JWQrCodeDemo
//
//  Created by GJW on 16/8/3.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "JWQrCodeSystem.h"
#import "JWHeader.h"

@implementation JWQrCodeSystem

#pragma mark - 灯
+ (void)boolOpenLight:(BOOL)open{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if (![device hasTorch]) {
    } else {
        if (open) {
            if(device.torchMode != AVCaptureTorchModeOn ||
               device.flashMode != AVCaptureFlashModeOn){
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
            }
        } else {
            if(device.torchMode != AVCaptureTorchModeOff ||
               device.flashMode != AVCaptureFlashModeOff){
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
            }
        }
    }
}

#pragma mark - 系统震动和声音
+ (void)boolOpenShake:(BOOL)boolShake boolSound:(BOOL)boolSound{
    if (boolShake) {
        //开启系统震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if (boolSound) {
        //设置自定义声音
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundPath ofType:soundType]], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

#pragma mark - Safari跳转
+ (void)showSafariWithURL:(NSString *)qrCodeInfo success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *newURl = [JWQrCodeSystem urlSchemes:qrCodeInfo];
    NSURL *url = [NSURL URLWithString:newURl];
    if ([newURl isEqualToString:qrCodeInfo]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            success(@"成功跳转");
            [[UIApplication sharedApplication] openURL:url];
        }else{
            NSError *error;
            failure(error);
        }
    }else{
        [[UIApplication sharedApplication] openURL:url];
    }
}
+ (NSString *)urlSchemes:(NSString *)urlString {
    NSString *newURL = nil;
    if ([urlString hasPrefix:@"http://qm.qq.com"]) {
        newURL = @"mqq://";
    }else if ([urlString hasPrefix:@"http://weixin.qq.com"]){
        newURL = @"weixin://";
    }else if ([urlString hasPrefix:@"http://weibo.cn"]){
        newURL = @"sinaweibo://";
    }else if ([urlString hasPrefix:@"https://qr.alipay.com"]){
        newURL = @"alipay://";
    }else{
        newURL = urlString;
    }
    return newURL;
}
@end
