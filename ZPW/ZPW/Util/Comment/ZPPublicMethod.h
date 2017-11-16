//
//  ZPPublicMethod.h
//  ZPW
//
//  Created by 张海军 on 2017/11/6.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ZPPublicMethod : NSObject

/**
 获取本地视频时间

 @param URL 本地视频地址
 @return 搭下
 */
+ (CGFloat)getVideoDuration:(NSURL*)URL;


/**
 获取本地视频大小

 @param path 视频路径
 @return 视频大小 b
 */
+ (NSInteger)getFileSize:(NSString*)path;


/**
 获取 Assert / ALAsset 文件名称

 @param asset Assert / ALAsset
 @return 名称
 */
+ (NSString *)getAssetsName:(id)asset;


/**
 获取 PHAsset 的url

 @param asset PHAsset
 @param result 路径回调
 */
+ (void)getfilePath:(PHAsset *)asset  Complete:(void(^)(NSURL *fileUrl))result;


/**
 <#Description#>

 @param asset PHAsset
 @param size 需要的大小
 @param result 返回的结果
 */
+ (void)getThumbnail:(PHAsset *)asset size:(CGSize)size result:(void(^)(UIImage *thumImage))result;

@end
