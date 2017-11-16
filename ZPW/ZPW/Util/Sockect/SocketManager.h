//
//  SocketManager.h
//  ZPW
//
//  Created by 张海军 on 2017/10/31.
//  Copyright © 2017年 baoqianli. All rights reserved.
//  socket断点上传文件

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SockerSendItem.h"

static NSString *const HOST = @"192.168.43.1";
static NSInteger const PORT = 8059;

@class SocketManager;

@protocol SocketManagerDelegate <NSObject>

@optional
// 正在上传的文件回调
- (void)socketManager:(SocketManager *)manager  itemUpingrefresh:(SockerSendItem *)upingItem;

// 文件上传完毕的回调
- (void)socketManager:(SocketManager *)manager  itemUpFinishrefresh:(SockerSendItem *)finishItem;

@end

@interface SocketManager : NSObject
/// delegate
@property (nonatomic, weak) id <SocketManagerDelegate> delegate;

/// 需传输的文件数组
@property (nonatomic, strong) NSMutableArray *needSendItems;
/// 连接状态改变的回调
@property (nonatomic, copy) void(^connectStateBlock)(BOOL isConnect);
/// 当前连接状态
@property (nonatomic, assign) BOOL isConnect;
/// 当前传输状态 是否正在传输
@property (nonatomic, assign) BOOL isSending;

/**
 初始化socket管理类

 @return SocketManager
 */
+ (instancetype)shareSocketManager;

/**
 tcp连接
 
 @param host ip地址
 @param port 端口号
 @return 是否连接成功
 */
- (BOOL)connentHost:(NSString *)host prot:(uint16_t)port;


/**
 传输对应文件

 @param dataItem 需传输文件的信息item
 */
- (void)sendDataWithItem:(SockerSendItem *)dataItem;



/**
 发送需要播放的指令

 @param dataItem 需要的播放的文件item
 */
- (void)sendPlayInstructions:(SockerSendItem *)dataItem;

/**
 列表文件是否传输完毕

 @return YES / NO
 */
- (BOOL)listSendIsFinish;

@end
