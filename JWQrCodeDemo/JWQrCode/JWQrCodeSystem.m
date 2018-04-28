//
//  JWQrCodeSystem.m
//  JWQrCodeDemo
//
//  Created by GJW on 16/8/3.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "JWQrCodeSystem.h"
#import "JWHeader.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface JWQrCodeSystem()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, copy) void(^blockPhoto)(NSString *qrCodeInfo);
@end
@implementation JWQrCodeSystem

#pragma mark - 灯
+ (void)qrCodeboolOpenLight:(BOOL)boolOpen{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if (![device hasTorch]) {
    } else {
        if (boolOpen) {
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
+ (void)qrCodeboolOpenShake:(BOOL)boolShake boolSound:(BOOL)boolSound{
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

#pragma mark - Safari跳转 - 添加常用APP跳转
+ (void)qrCodeShowSafariWithURL:(NSString *)qrCodeInfo success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
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
+ (UIImage *)qrCodeGenerateWithString:(NSString *)string qrCodeSize:(CGFloat)qrCodeSize{
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

#pragma mark  - 打开相册扫码
- (BOOL)qrCodeWithOpenPhotoAlbum:(UIViewController *)vc{
    //1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return NO;
    }
    //2.创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    //选中之后大图编辑模式
    ipc.allowsEditing = YES;
    [vc presentViewController:ipc animated:YES completion:nil];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
//相册获取的照片进行处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // 1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    
    CIImage *ciImage = [CIImage imageWithCGImage:pickImage.CGImage];
    
    //2.从选中的图片中读取二维码数据
    //2.1创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    // 2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];
    
    // 2.3取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        NSString *urlStr = result.messageString;
        //二维码信息回传
//        if (_showQRCodeInfo) {
//            self.block(urlStr);
//        }
        [JWQrCodeSystem qrCodeShowSafariWithURL:urlStr success:^(NSString *responseObject) {
        } failure:^(NSError *error) {
//           [self showAlertWithTitle:@"该信息无法跳转，详细信息为：" Message:urlStr OptionalAction:@[@"确定"]]; 
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (feature.count == 0) {
//        [self showAlertWithTitle:@"扫描结果" Message:@"没有扫描到有效二维码" OptionalAction:@[@"确认"]];
    }
}

@end
