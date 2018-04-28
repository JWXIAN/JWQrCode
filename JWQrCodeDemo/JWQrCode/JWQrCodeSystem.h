//
//  JWQrCodeSystem.h
//  JWQrCodeDemo
//
//  Created by GJW on 16/8/3.
//  Copyright © 2016年 JW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JWQrCodeSystem : NSObject
/**
 *  是否开启灯光
 *
 *  @param open 是否打开
 */
+ (void)qrCodeboolOpenLight:(BOOL)boolOpen;

/**
 *  是否开启震动和声音
 *
 *  @param boolShake 震动
 *  @param boolSound 声音
 */
+ (void)qrCodeboolOpenShake:(BOOL)boolShake boolSound:(BOOL)boolSound;

/**
 *  Safari打开扫描信息
 *
 *  @param qrCodeInfo 扫描信息
 *  @param success 成功信息
 *  @param failure 失败信息
 */
+ (void)qrCodeShowSafariWithURL:(NSString *)qrCodeInfo success:(void(^)(NSString *responseObject))success failure:(void (^)(NSError *error))failure;

/**
 *  生成二维码
 *
 *  @param string 二维码信息
 *  @param qrCodeSize 二维码Size
 *
 *  @return UIImage
 */
+ (UIImage *)qrCodeGenerateWithString:(NSString *)string qrCodeSize:(CGFloat)qrCodeSize;

/**
 *  打开相册图片扫码
 *
 *  @param vc vc
 */
- (BOOL)qrCodeWithOpenPhotoAlbum:(UIViewController *)vc;
@end
