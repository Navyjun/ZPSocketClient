//
//  SockerSendItem.h
//  ZPW
//
//  Created by 张海军 on 2017/11/1.
//  Copyright © 2017年 baoqianli. All rights reserved.
//  tcp 发送文件模型

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SENDFILE_TYPE)
{
    SENDFILE_TYPE_FILEINFOLIST = 0,// 列表
    SENDFILE_TYPE_IMAGE = 1,   // 图片
    SENDFILE_TYPE_VIDEO,       // 视频
    SENDFILE_TYPE_AUDIO,       // 音频
    SENDFILE_TYPE_TEXT         // 文字
};

// SENDFILE_TYPE_FILEINFOLIST
// SENDFILE_TYPE_FILEHEADINFO

@interface SockerSendItem : NSObject
/// 文件名称
@property (nonatomic, copy) NSString *fileName;
/// 文件类型
@property (nonatomic, assign) SENDFILE_TYPE type;
/// 文件总大小
@property (nonatomic, assign) NSInteger fileSize;
/// 文件已上传大小
@property (nonatomic, assign) NSInteger upSize;
/// 资源路径
@property (nonatomic, copy) NSURL *filePath;
/// id 序列号
@property (nonatomic, assign) NSInteger index;
/// 是否正在上传中
@property (nonatomic, assign) BOOL isSending;
/// 当前文件是否已经全部传输完毕
@property (nonatomic, assign) BOOL isSendFinish;
/// 文件类型
@property (nonatomic, copy) NSString *typeStr;
/// 资源文件
@property (nonatomic, strong) id asset;
/// 缩略图路径
@property (nonatomic, copy) NSString *thumImgPath;
/// 是否需要取消传输(isSending = NO && isSendFinish = NO)是有效
@property (nonatomic, assign) BOOL isCancleSend;
@end
