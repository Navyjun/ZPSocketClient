//
//  NSString+path.h
//  baiSi
//
//  Created by 张海军 on 15/12/22.
//  Copyright © 2015年 gegejia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (path)
/**
 *  生成缓存目录全路径
 */
- (instancetype)cacheDir;
/**
 *  生成文档目录全路径
 */
- (instancetype)docDir;
/**
 *  生成临时目录全路径
 */
- (instancetype)tmpDir;

/**
 *  json字符串转字典
 */
- (NSMutableDictionary *)hj_jsonStringToDic;

/**
 *  NSData转成16进制字符串
 */
+ (NSString *)hj_hexStringFromString:(NSData *)myData;

/**
 *  十六进制文字转颜色
 */
+ (UIColor *)colorWithHexString: (NSString *)color;
/**
 *  通过最大的宽度来计算高度
 */
- (CGSize)hj_stringHeightWithMaxWidth:(CGFloat)maxWidth andFont:(UIFont*)font;
/**
 *  通过最大高度来计算宽度
 */
- (CGSize)hj_stringWidthWithMaxHeight:(CGFloat)maxHeight andFont:(UIFont*)font;
/**
 *  将十六进制的编码转为emoji字符
 */
+ (NSString *)emojiWithIntCode:(int)intCode;

/**
 *  将十六进制的编码转为emoji字符
 */
+ (NSString *)emojiWithStringCode:(NSString *)stringCode;
- (NSString *)emoji;

/**
 *  是否为emoji字符
 */
- (BOOL)isEmoji;

// 手机号的验证
- (BOOL)hj_isValidPhone;

// 替换字符串里面的空格 或换行符
- (NSString *)hj_replaceEmpty;

+ (NSString *)hj_dicToJsonStr:(NSDictionary *)dic;


/**
 当前日期是否大于等于这个日期的多少天

 @param day 日期限定 <30天内>
 @return 是否大于等于
 */
- (BOOL)hj_nowDateisSurpassHowMuchDay:(NSInteger)day;

/**
 YYYY-MM-DD HH:mm:ss

 @return 时间样式
 */
- (NSString *)hj_timeToYMDHMS;

/**
 YYYY-MM-DD
 
 @return 时间样式
 */
- (NSString *)hj_timeToYMD;


/**
 时间格式化字符串

 @param date 日期
 @return HH:mm
 */
+ (NSString *)hj_timeHHmm:(NSDate*)date;

+ (NSString *)hj_timeYYYYMMdd:(NSDate*)date;

/**
 身份证校验

 @param IDCardNumber 身份证号码
 @return YES / NO
 */
+ (BOOL)IsIdentityCard:(NSString *)IDCardNumber;

+ (BOOL)stringContainsEmoji:(NSString *)string;


/**
 清空当前路径下的文件夹

 @param path 路径
 @return 是否成功
 */
+ (BOOL)clearCacheWithFilePath:(NSString *)path;
@end
