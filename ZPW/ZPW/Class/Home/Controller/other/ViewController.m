//
//  ViewController.m
//  ZPW
//
//  Created by 张海军 on 2017/10/26.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ViewController.h"
#import "HJWifiUtil.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

static int port = 8089;//8080;

@interface ViewController () <GCDAsyncUdpSocketDelegate>
@property(strong,nonatomic) GCDAsyncSocket* clientSocket;
///
@property (nonatomic, strong) GCDAsyncUdpSocket *sendUdpSocket;;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"wifi info = %@",[HJWifiUtil getLocalInfoForCurrentWiFi]);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)btStart {

    _sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 启用广播
    NSError *broadError = nil;
    [_sendUdpSocket enableBroadcast:YES error:&broadError];
    if (broadError) {
        NSLog(@"broadError = %@",broadError);
    }
    
    // 绑定端口
    NSError * error = nil;
    [_sendUdpSocket bindToPort:8080 error:&error];
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        // 开始接受数据
        NSError *receivError = nil;
        [_sendUdpSocket beginReceiving:&receivError];
        if (receivError) {
            NSLog(@"receivError = %@",receivError);
        }
    }
    
    [self connectSocket];
}

/// 连接socket
- (void)connectSocket{
    BOOL isCon = [_sendUdpSocket isConnected];
    
    if (!isCon) {
        NSError *error = nil;
        // 8099 8080     192.168.43.1   172.21.64.4   192.168.2.85
        [_sendUdpSocket connectToHost: @"192.168.2.4" onPort:8099 error:&error];
        
        NSError *enableError = nil;
        [_sendUdpSocket enableBroadcast:YES error:&enableError];
        
        if (error) {
            NSLog(@"error = %@",error);
        }
        
        if (enableError) {
            NSLog(@"enableError = %@",enableError);
        }
    }
}

- (IBAction)btSendMsg:(id)sender {

    if ([_sendUdpSocket isConnected]) {
        NSString *s = @"MSG_FILE_RECEIVER_INIT";
        NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
        
//        UIImage *image = [UIImage imageNamed:@"icon_WeChat-"];
//        NSData *imgData = UIImagePNGRepresentation(image);
        
        [_sendUdpSocket sendData:data withTimeout:30 tag:10];
    }else{
        NSLog(@"socket 未连接 从新连接");
        [self connectSocket];
    }
}


#pragma mark -

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"%s \n connectedHost = %@ \n connectedAddress = %@ \n connectedPort = %hu",__func__,[sock connectedHost],address,[sock connectedPort]);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{
    NSLog(@"%s",__func__);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
    NSLog(@"%s \n connectedHost = %@ \n connectedAddress = %@ \n connectedPort = %hu \n tag = %ld",__func__,[sock connectedHost],[sock connectedAddress],[sock connectedPort],tag);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
     NSLog(@"%s %@",__func__,error);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
    NSLog(@"%s \n connectedHost = %@ \n connectedAddress = %@ \n connectedPort = %hu",__func__,[sock connectedHost],address,[sock connectedPort]);
     NSLog(@"%s \n%@ \n%@",__func__,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],filterContext);
    
    /* 连续写入文件
     NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"path"];
     [fileHandle seekToEndOfFile];
     [fileHandle writeData:data];
     [fileHandle closeFile];
     [sock readDataWithTimeout:-1 tag:200];
     */
    
}


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{
    NSLog(@"%s error = %@",__func__,error);
}

-(NSString *)ConvertToNSString:(NSData *)data
{
    NSMutableString *strTemp = [NSMutableString stringWithCapacity:[data length]*2];
    const unsigned char *szBuffer = [data bytes];
    for (NSInteger i=0; i < [data length]; ++i) {
        [strTemp appendFormat:@"%02lx",(unsigned long)szBuffer[i]];
    }
    return strTemp;
}

/*
 
 - (void)rightItemClick{
 NSInteger sourceType = 0;
 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
 sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 } else {
 sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 }
 
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 
 NSArray *arr = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
 NSMutableArray *marr = [NSMutableArray array];
 for (NSInteger i = 0; i < arr.count; i++) {
 if ([arr[i] isEqualToString:@"public.movie"] || [arr[i] isEqualToString:@"public.image"]) {
 [marr addObject:arr[i]];
 }
 }
 imagePicker.mediaTypes = marr;
 imagePicker.delegate = self;
 imagePicker.sourceType = sourceType;
 imagePicker.allowsEditing = YES;
 [self presentViewController:imagePicker animated:YES completion:nil];
 }

 
 #pragma mark - UIImagePickerControllerDelegate
 
 -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
 NSLog(@" infoDic = %@",info);
 
 [picker dismissViewControllerAnimated:YES completion:^{
 
 SockerSendItem *sendItem = [[SockerSendItem alloc] init];
 NSString *refreshceurl = nil;
 if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
 sendItem.filePath = info[@"UIImagePickerControllerImageURL"];
 sendItem.type = SENDFILE_TYPE_IMAGE;
 refreshceurl = [info[@"UIImagePickerControllerReferenceURL"] absoluteString];
 }else if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"] ||
 [info[UIImagePickerControllerMediaType] isEqualToString:@"public.mov"]){
 sendItem.filePath = info[@"UIImagePickerControllerMediaURL"] ;
 sendItem.type = SENDFILE_TYPE_VIDEO;
 refreshceurl = [info[@"UIImagePickerControllerReferenceURL"] absoluteString];
 }
 
 //sendItem.fileSize = [self getFileSize:[[sendItem.filePath absoluteString] substringFromIndex:16]];
 sendItem.fileSize = [self getFileSize:sendItem.filePath];
 
 NSRange range = [refreshceurl rangeOfString:@"?id="];
 sendItem.fileName = [[refreshceurl substringFromIndex:(range.location+4)] stringByReplacingOccurrencesOfString:@"=" withString:@"."];
 
 sendItem.index = self.sendItemArray.count;
 [self.sendItemArray addObject:sendItem];
 [self.tableView reloadData];
 }];
 }

 
 */


@end
