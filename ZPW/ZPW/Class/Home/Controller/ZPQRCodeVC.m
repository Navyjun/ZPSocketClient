//
//  ZPQRCodeVC.m
//  ZPW
//
//  Created by 张海军 on 2017/11/8.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ZPQRCodeVC.h"
#import "ZPHomeViewController.h"
#import "SocketManager.h"
#import "HJWifiUtil.h"

@interface ZPQRCodeVC ()
/// wifiNameLabel
@property (nonatomic, strong) UILabel *wifiNameLabel;
@end

@implementation ZPQRCodeVC
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描连接";
    self.view.backgroundColor=[UIColor blackColor];
    self.style = [self qqLBXScanViewStyle];
    
    self.wifiNameLabel = [[UILabel alloc] init];
    self.wifiNameLabel.frame = CGRectMake(0, 0, self.view.frame.size.width,100);
    self.wifiNameLabel.textAlignment = NSTextAlignmentCenter;
    self.wifiNameLabel.textColor = [UIColor whiteColor];
    self.wifiNameLabel.font = [UIFont systemFontOfSize:14.0];
//    self.wifiNameLabel.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.wifiNameLabel];
    
    self.wifiNameLabel.text = [NSString stringWithFormat:@"当前连接wifi:%@",[HJWifiUtil fetchWiFiName]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    MYLog(@"扫描界面被销毁");
}

#pragma mark
- (LBXScanViewStyle *)qqLBXScanViewStyle
{
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    style.animationImage = [UIImage imageNamed:@"qrcode_scan_light_green"];
    return style;
}

//获得扫码的结果
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    
    if (array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (LBXScanResult *result in array) {
        
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    if (strResult.length > 0) {
        //[ToastManager showToastWithString:strResult];
        [self pushToAddUserVC:strResult];
    }
    
    //self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //震动提醒
    [LBXScanWrapper systemVibrate];
    //声音提醒
    [LBXScanWrapper systemSound];
    
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        strResult = @"识别失败";
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reStartDevice];
    });
    
    
}


-(void)myAction
{
    if ([LBXScanWrapper isGetPhotoPermission])
        [self openLocalPhoto];
    else
    {
        [self showError:@"      请到设置->隐私中开启本程序相册权限     "];
    }
}


/**
 进入传输页面
 {"ipAddress":"192.168.43.1","port":8059,"wifiName":"NX549J"}
 @param result 扫描结果
 */
- (void)pushToAddUserVC:(NSString *)result
{
    NSDictionary *dic = [result hj_jsonStringToDic];
    MYLog(@"dic = %@",dic);
    
    if (dic == nil || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"非法二维码,请重新扫描");
        [self reStartQR];
        return;
    }
    
    NSString *ipAddress = dic[@"ipAddress"];
    NSString *port = dic[@"port"];
    NSString *wifiName = dic[@"wifiName"];
    
    if (!ipAddress.length || !port || !wifiName.length) {
        NSLog(@"ipAddress = %@ \n port = %@ \n wifiName = %@",ipAddress,port,wifiName);
        [self reStartQR];
        return;
    }
    
    CURRENT_HOST = ipAddress;
    CURRENT_PORT = port.integerValue;
    CURRENT_WIFINAME = wifiName;
    
    [[SocketManager shareSocketManager] connentHost:CURRENT_HOST prot:CURRENT_PORT];
    ZPHomeViewController *homeVC = [[ZPHomeViewController alloc] init];
    [self.navigationController pushViewController:homeVC animated:YES];
    
}


- (void)reStartQR
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reStartDevice];
    });
}

@end
