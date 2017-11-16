//
//  TcpViewController.m
//  ZPW
//
//  Created by 张海军 on 2017/10/30.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "TcpViewController.h"
#import "HJWifiUtil.h"
#import "GCDAsyncSocket.h"

@interface TcpViewController ()<GCDAsyncSocketDelegate>
///
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@property (weak, nonatomic) IBOutlet UITextField *targetPort;
@property (weak, nonatomic) IBOutlet UITextField *sendPort;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;

///
@property (nonatomic, assign)  NSUInteger totalLength;

@end

@implementation TcpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSLog(@"wifi info = %@",[HJWifiUtil getLocalInfoForCurrentWiFi]);
    
//    MPMediaQuery   *everything = [[MPMediaQuery alloc] init];
//    MPMediaPropertyPredicate  *album = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType];
//    [everything addFilterPredicate:album];
//    NSArray   *items = [everything items];
//    for (MPMediaItem  *song in items) {
//        NSString *songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
//        NSLog(@"songTitle = %@", songTitle);
//    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - init
- (void)connectSocket{
//    [self.asyncSocket disconnect];
    
//    NSError *error = nil;
//    [self.asyncSocket acceptOnPort:self.targetPort.text.integerValue error:&error];
    
    if (![self.asyncSocket isConnected]) {
        NSError *conError = nil;
        [self.asyncSocket connectToHost:self.ipTextField.text
                                 onPort:self.sendPort.text.integerValue
                                  error:&conError];
        
        if (conError) {
            NSLog(@"连接失败 conError = %@",conError);
            return;
        }
        
        // 可读取服务端数据
        [self.asyncSocket readDataWithTimeout:- 1 tag:0];
    }
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark - event
- (IBAction)startPort:(id)sender {
    [self connectSocket];
}


- (IBAction)sendMessage:(id)sender {
    
    NSInteger headLen = 1024;
    NSString *headStr = @"拼接头部测试";
    headLen = headLen - [self convertToByte:headStr];
    NSLog(@"headStr = %d",[self convertToByte:headStr]);
    for (NSInteger i = 0 ; i < headLen; i++) {
        headStr = [NSString stringWithFormat:@"%@ ",headStr];
    }
    NSData *headData = [headStr dataUsingEncoding:NSUTF8StringEncoding];

    UIImage *img = [UIImage imageNamed:@"参团-参团成功"];
    NSData *imgData = UIImagePNGRepresentation(img);
    NSLog(@"imgData = %ld",imgData.length);
    
    NSMutableData *sendData = [NSMutableData dataWithData:headData];
    [sendData appendData:imgData];
//    [sendData appendData:[@"-1" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.asyncSocket writeData:sendData withTimeout:- 1 tag:0];
    
    
//    NSData *thumImgData = UIImagePNGRepresentation([UIImage imageNamed:@"参团-参团成功"]);
//    [self.asyncSocket writeData:thumImgData withTimeout:-1 tag:10];
    
}


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
    //NSLog(@"strlength = %d",strlength);
    return strlength;
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"%s",__func__);
    NSLog(@"%@",[NSString stringWithFormat:@"客户端的地址: %@ -------端口: %d", newSocket.connectedHost, newSocket.connectedPort]);
    [newSocket readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
     NSLog(@"%s \n host = %@ \n port = %d",__func__,host,port);
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%s \n didReadData = %zd \n tag = %ld \n data = %@",__func__,data.length,tag,data);
    NSLog(@"didReadData = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    // 读取到服务器数据值后也能再读取
    [sock readDataWithTimeout:-1 tag:200];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
    NSLog(@"%s \n partialLength = %zd \n tag = %ld",__func__,partialLength,tag);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
      [self.asyncSocket setAutoDisconnectOnClosedReadStream:YES];
      NSLog(@"%s \n tag = %ld",__func__,tag);
      NSLog(@"totalLength = %ld",self.totalLength);
    
}


- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"%s \n partialLength = %lu, tag = %ld",__func__,(unsigned long)partialLength,tag);
    self.totalLength += partialLength;
   
}


- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    NSLog(@"%s",__func__);
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%s",__func__);
}


- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    NSLog(@"%s",__func__);
}



#pragma mark -----
- (void)headListEp{
    NSInteger headLen = 1024;
    NSString *headStr = @"拼接头部测试";
    headLen = headLen - [self convertToByte:headStr];
    NSLog(@"headStr = %d",[self convertToByte:headStr]);
    for (NSInteger i = 0 ; i < headLen; i++) {
        headStr = [NSString stringWithFormat:@"%@ ",headStr];
    }
    NSData *headData = [headStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *s = @"\nend\n";//@"MSG_FILE_RECEIVER_INIT";
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    /*
     0:图片
     1:视频
     2:音频
     4:文字
     */
    //    NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"icon_WeChat-"]);
    NSArray *jsonArray = @[
                           @{@"fileName" : @"12345.jpeg",
                             @"fileType" : @0,
                             @"fileSize" : @10000,
                             //                                @"fileThumbnail" : imgData
                             },
                           @{
                               @"fileName" : @"测试视频.MP4",
                               @"fileType" : @1,
                               @"fileSize" : @10000,
                               //                                  @"fileThumbnail" : imgData
                               },
                           @{
                               @"fileName" : @"测试音频.MP3",
                               @"fileType" : @2,
                               @"fileSize" : @10000,
                               //                                  @"fileThumbnail" : imgData
                               }
                           ];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    //    NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:j's];
    
    NSMutableData *sendData = [NSMutableData dataWithData:headData];
    [sendData appendData:jsonData];
    [sendData appendData:data];
    [self.asyncSocket writeData:sendData withTimeout:- 1 tag:0];
}


@end
