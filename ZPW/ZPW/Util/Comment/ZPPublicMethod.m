//
//  ZPPublicMethod.m
//  ZPW
//
//  Created by 张海军 on 2017/11/6.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ZPPublicMethod.h"


@implementation ZPPublicMethod

//获取视频时间
+ (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

//获取视频 大小
+ (NSInteger) getFileSize:(NSString*)path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ((theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

/// 获取asset名字
+ (NSString *)getAssetsName:(id)asset {
    NSString *fileName;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        fileName = [phAsset valueForKey:@"filename"];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        fileName = alAsset.defaultRepresentation.filename;;
    }
    NSLog(@"fileName = %@",fileName);
    return fileName;
}


/// 通 PHAsset 获取文件url
+ (void)getfilePath:(PHAsset *)asset  Complete:(void(^)(NSURL *fileUrl))result{
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        PHVideoRequestOptions *videoOption = [[PHVideoRequestOptions alloc] init];
        videoOption.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoOption resultHandler:^(AVAsset * _Nullable videoAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)videoAsset;
            result(urlAsset.URL);
        }];
        
        
    }else if (asset.mediaType == PHAssetMediaTypeImage){
        
        // 获取图片资源路径
        PHContentEditingInputRequestOptions *reqOption = [[PHContentEditingInputRequestOptions alloc] init];
        reqOption.canHandleAdjustmentData = ^(PHAdjustmentData * _Nonnull adjustmentData) {
            return YES;
        };
        
        [asset requestContentEditingInputWithOptions:reqOption completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            result(contentEditingInput.fullSizeImageURL);
        }];
        
    }
}

// 获取图片 / 视频 缩略图
+ (void)getThumbnail:(PHAsset *)asset size:(CGSize)size result:(void(^)(UIImage *thumImage))result{
    //if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage *image, NSDictionary *info) {
                                                    if (result) {
                                                        result(image);
                                                    }
                                                }];
//    }else if (asset.mediaType == PHAssetMediaTypeVideo){
//
//    }
    
    
}

@end
