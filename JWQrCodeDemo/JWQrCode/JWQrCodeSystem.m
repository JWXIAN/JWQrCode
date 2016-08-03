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

#pragma mark - 生成二维码
+ (UIImage *)generateQrCodeWithString:(NSString *)string qrCodeSize:(CGFloat)qrCodeSize{
    if (!string) return nil;
    //二维码滤镜
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复滤镜的默认属性
    [filter setDefaults];
    //将字符串转换成NSData
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    //通过KVO设置滤镜inputmessage数据
    [filter setValue:data forKey:@"inputMessage"];
    //获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    //将CIImage转换成UIImage,并放大显示
    UIImage *image = [UIImage new];
    image = [JWQrCodeSystem createNonInterpolatedUIImageFormCIImage:outputImage withSize:qrCodeSize?qrCodeSize:200];
    return image;
}

#pragma mark - 改变二维码大小
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
@end
