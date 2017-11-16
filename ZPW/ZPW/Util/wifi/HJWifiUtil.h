//
//  HJWifiUtil.h
//  ZPW
//
//  Created by 张海军 on 2017/10/26.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJWifiUtil : NSObject

/**
 * 获取WiFi 信息，返回的字典中包含了WiFi的名称、路由器的Mac地址、还有一个Data(转换成字符串打印出来是wifi名称)
 * BSSID = "a4:2b:8c:c:7f:bd"; 唯一的
 * SSID = bdmy06; 名称
 * SSIDDATA = <73756e65 65653036>;
 */

+ (NSDictionary *)fetchSSIDInfo;

/**
 获取wifi名称
 
 @return wifi名称
 */
+ (NSString *)fetchWiFiName;

/**
 获取网关
 
 @return 网关
 */
+ (NSString *)getGatewayIpForCurrentWiFi;

/**
 获取wifi环境下本机ip地址
 
 @return ip地址
 */
+ (NSString *)getLocalIPAddressForCurrentWiFi;

/**
 获取广播地址、子网掩码、端口
 
 @return 广播地址/子网掩码/端口集合
 */
+ (NSMutableDictionary *)getLocalInfoForCurrentWiFi;

@end
