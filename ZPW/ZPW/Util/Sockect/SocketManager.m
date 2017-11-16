//
//  SocketManager.m
//  ZPW
//
//  Created by 张海军 on 2017/10/31.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "SocketManager.h"
#import "GCDAsyncSocket.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "NSString+path.h"

static NSInteger LISTTAG = 9999; // 列表标识
static NSInteger FILEHEADTAG = 99999; // 文件头部标识

// 列表传输完毕 服务端发送的字符
static NSString *const FILE_LIST_SEND_END = @"FILE_LIST_SEND_END";
// 文件头部传输完毕 服务端发送的字符
static NSString *const FILE_HEAD_SEND_END = @"FILE_HEAD_SEND_END";

// 传输列表的标识符
static NSString *const SENDFILETYPEFILEINFOLIST = @"SENDFILE_TYPE_FILEINFOLIST";
// 传输文件头部的标识符
static NSString *const SENDFILETYPEFILEHEADINFO = @"SENDFILE_TYPE_FILEHEADINFO";
// 发送需要播放的文件指令头
static NSString *const PLAYSENDFILEHEAD = @"PLAY_SENDFILE_HEAD";


@interface SocketManager ()<GCDAsyncSocketDelegate>
/// socket
@property (nonatomic, strong) GCDAsyncSocket *tcpSocketManager;
/// 当前在传的文件
@property (nonatomic, strong) SockerSendItem *currentSendItem;
@end


@implementation SocketManager
static SocketManager *manager = nil;

#pragma mark - init
+ (instancetype)shareSocketManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)setNeedSendItems:(NSMutableArray *)needSendItems{
    _needSendItems = needSendItems;
    
    if (needSendItems.count <= 0) {
        return;
    }
   
    // 固定头部
    SockerSendItem *headItem = [[SockerSendItem alloc] init];
    headItem.index = LISTTAG;
    headItem.fileName = @"列表";
    NSData *headData = [self creationHeadStr:headItem];

    // 列表数据
    NSInteger count = needSendItems.count;
    NSMutableArray *itemDicArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        SockerSendItem *item = needSendItems[i];
        item.index = i;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"fileName"] = item.fileName;
        dic[@"fileType"] = [NSNumber numberWithInteger:item.type];
        dic[@"fileSize"] = [NSNumber numberWithInteger:item.fileSize];
        dic[@"id"] = [NSNumber numberWithInteger:item.index];
        [itemDicArray addObject:dic];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDicArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];

    // 尾部拼接
    NSString *s = @"\nend\n";
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *listHeadData = [NSMutableData dataWithData:headData];
    [listHeadData appendData:jsonData];
    [listHeadData appendData:data];
    [self.tcpSocketManager writeData:listHeadData withTimeout:-1 tag:LISTTAG];
    MYLog(@"listHeadData = %@",[[NSString alloc] initWithData:listHeadData encoding:NSUTF8StringEncoding]);
    
}


#pragma mark - method
- (BOOL)connentHost:(NSString *)host prot:(uint16_t)port{
    if (host==nil || host.length <= 0) {
        NSAssert(host != nil, @"host must be not nil");
    }
    
    // 确保先断开连接
    [self.tcpSocketManager disconnect];
    self.tcpSocketManager.delegate = nil;
    self.tcpSocketManager = nil;
    if (self.tcpSocketManager == nil) {
        self.tcpSocketManager = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    NSError *connectError = nil;
    [self.tcpSocketManager connectToHost:host onPort:port error:&connectError];
    
    if (connectError) {
        MYLog(@"连接失败");
        return NO;
    }
    // 可读取服务端数据
    [self.tcpSocketManager readDataWithTimeout:-1 tag:0];
    return YES;
}

// 发送播放指令
- (void)sendPlayInstructions:(SockerSendItem *)dataItem{
    [self sendFileHeadStr:dataItem isPlay:YES];
}

// 发送文件
- (void)sendDataWithItem:(SockerSendItem *)sendItem{
    self.currentSendItem = sendItem;
    if ((sendItem.type == SENDFILE_TYPE_IMAGE || sendItem.type == SENDFILE_TYPE_VIDEO)) { // 视频 图片的传输
        [self imageOrVideoFileSend:sendItem];
    }
    
}

// 图片或者视频文件传输
- (void)imageOrVideoFileSend:(SockerSendItem *)sendItem{
    PHAsset *asset = (PHAsset *)sendItem.asset;
    [ZPPublicMethod getfilePath:asset Complete:^(NSURL *fileUrl) {
        MYLog(@"currentThread = %@",[NSThread currentThread]);
        sendItem.filePath = fileUrl;
        [self writeDataWithItem:sendItem];
    }];
}

// 传输数据到服务端
- (void)writeDataWithItem:(SockerSendItem *)sendItem{
    NSData *sendData = [NSData dataWithContentsOfURL:sendItem.filePath options:NSDataReadingMappedIfSafe error:nil];
    MYLog(@"sendData = %zd",sendData.length);
    [self.tcpSocketManager writeData:sendData withTimeout:-1 tag:sendItem.index];
}

// 发送文件头部信息 固定头部
- (void)sendFileHeadStr:(SockerSendItem *)dataItem isPlay:(BOOL)paly{
    // 规则 头部 1024字节长度  不足的 拼接 空格
    NSString *headStr = [NSString stringWithFormat:@"%@\n",paly ? PLAYSENDFILEHEAD : SENDFILETYPEFILEHEADINFO];
    NSData *headStrData = [headStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"fileName"] = dataItem.fileName;
    dic[@"fileType"] = [NSNumber numberWithInteger:dataItem.type];
    dic[@"fileSize"] = [NSNumber numberWithInteger:dataItem.fileSize];
    dic[@"id"] = [NSNumber numberWithInteger:dataItem.index];
    dic[@"isCancel"] = [NSNumber numberWithInt:(dataItem.isCancleSend?1:0)];
    dic[@"w"]  = [NSNumber numberWithInteger:1080];
    dic[@"h"]  = [NSNumber numberWithInteger:1920];
    NSString *bodStr = [NSString hj_dicToJsonStr:dic];
    NSMutableData *sendData = [NSMutableData dataWithData:headStrData];
    [sendData appendData:[bodStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *s = @"\nend\n";
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    [sendData appendData:data];
    MYLog(@"文件头传输 = %@ +++ %@",dic,[[NSString alloc] initWithData:headStrData encoding:NSUTF8StringEncoding]);
    [self.tcpSocketManager writeData:sendData withTimeout:-1 tag:FILEHEADTAG];
}

// 创建固定头部 用于拼接 <目前只是固定用于列表>
- (NSData *)creationHeadStr:(SockerSendItem *)dataItem{
    NSString *headStr = [NSString stringWithFormat:@"%@\n",SENDFILETYPEFILEINFOLIST];//
    return [headStr dataUsingEncoding:NSUTF8StringEncoding];
}

// 字符串字节数
- (int)convertToByte:(NSString*)str {
    int strlength = 0;
    char* p = (char*)[str cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i=0 ; i<[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}



/**
 遍历需要传输的文件数组 拿到最新需要上传的item

 @param needSend 遍历后的回到  ifFinish:当前数组是否已经全部传完  sendItem:需要传输的文件item
 */
- (void)ergodicNeedSendFile:(void(^)(BOOL isFinish, SockerSendItem *sendItem))needSend{
    BOOL finish = YES;
    SockerSendItem *sendItem = nil;
    for (SockerSendItem *item in self.needSendItems) {
        if (item.isSendFinish == NO) {
            finish = NO;
            sendItem = item;
            break;
        }
    }
    
    if (needSend) {
        needSend(finish,sendItem);
    }
    
}


/// 列表是否传输完毕
- (BOOL)listSendIsFinish{
    BOOL finish = YES;
    if (self.needSendItems.count == 0) {
        return NO;
    }
    for (SockerSendItem *item in self.needSendItems) {
        if (item.isSendFinish == NO && item.isCancleSend == NO) {
            return NO;
        }
    }
    return finish;
}

#pragma mark - GCDAsyncSocketDelegate
// 作为服务端时 当有新的客户端加入
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [newSocket readDataWithTimeout:-1 tag:0];
}

// 连接到对应的 服务端成功的回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.isConnect = YES;
    if (self.connectStateBlock) {
        self.connectStateBlock(YES);
    }
}

// 接受到服务端回调的信息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *readStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    MYLog(@"didReadData = %@ tag = %zd",readStr,tag);
    // 文件列表json传输完毕
    if ([readStr containsString:FILE_LIST_SEND_END]) {
        // 传输第一个实体文件的头部信息
        if (self.needSendItems.count > 0) {
            [self sendFileHeadStr:self.needSendItems[0] isPlay:NO];
        }
    }else if ([readStr containsString:FILE_HEAD_SEND_END]){ // 实体文件头部信息传输完毕
        NSString *Str = [readStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSInteger index = [[Str substringFromIndex:FILE_HEAD_SEND_END.length] intValue];
        MYLog(@"index = %zd",index);
        if (index < self.needSendItems.count) {
            SockerSendItem *item = self.needSendItems[index];
            if (item.isCancleSend) { // 发送下一个头文件
                NSInteger nextIndex = index +1;
                if (nextIndex < self.needSendItems.count) {
                    [self sendFileHeadStr:self.needSendItems[nextIndex] isPlay:NO];
                }
            }else{
                [self sendDataWithItem:item];
            }
        }
    }
    
    // 读取到服务器数据值后也能再读取
    [sock readDataWithTimeout:-1 tag:tag];
    
}

// 分段读取大文件
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
    MYLog(@"%s \n partialLength = %zd \n tag = %ld",__func__,partialLength,tag);
}

// 文件传输完毕后的回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    MYLog(@"%s \n tag = %ld",__func__,tag);
    // 上一个文件传输完毕后 传输下一个
    if (tag == self.currentSendItem.index) {
        MYLog(@"%@文件已传输完毕 \n index = %zd",self.currentSendItem.fileName,self.currentSendItem.index);
        // 上一个文件传输完毕 标记
        self.currentSendItem.isSendFinish = YES;
        self.currentSendItem.isSending = NO;
        if ([self.delegate respondsToSelector:@selector(socketManager:itemUpFinishrefresh:)]) {
            [self.delegate socketManager:self itemUpFinishrefresh:self.needSendItems[tag]];
        }
        
        // 开始传输下一个文件的头部
        NSInteger nextIndex = tag + 1;
        if (nextIndex < self.needSendItems.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MYLog(@"第%zd个文件传输完毕 \n 第%zd文件头传输",tag,nextIndex);
                [self sendFileHeadStr:self.needSendItems[nextIndex] isPlay:NO];
            });
        }
    }
    
    [self.tcpSocketManager setAutoDisconnectOnClosedReadStream:YES];
    
}


// 分段传输完成后的 回调
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    self.currentSendItem.upSize += partialLength;
    if ([self.delegate respondsToSelector:@selector(socketManager:itemUpingrefresh:)] && (tag<self.needSendItems.count)) {
        SockerSendItem *item = self.needSendItems[tag];
        item.isSending = YES;
        [self.delegate socketManager:self itemUpingrefresh:item];
    }
    MYLog(@"%f--tag = %zd",((self.currentSendItem.upSize * 1.0) / self.currentSendItem.fileSize),tag);
}


- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    MYLog(@"%s",__func__);
}

// 断开连接的回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    self.isConnect = NO;
    if (self.connectStateBlock) {
        self.connectStateBlock(NO);
    }
}


- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    MYLog(@"%s",__func__);
}


@end

