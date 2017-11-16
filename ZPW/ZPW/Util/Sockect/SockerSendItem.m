//
//  SockerSendItem.m
//  ZPW
//
//  Created by 张海军 on 2017/11/1.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "SockerSendItem.h"

@implementation SockerSendItem

- (NSString *)typeStr{
    if (self.type == SENDFILE_TYPE_IMAGE) {
        return @"图片";
    }else if (self.type == SENDFILE_TYPE_AUDIO){
        return @"音频";
    }else if (self.type == SENDFILE_TYPE_VIDEO){
        return @"视频";
    }else if (self.type == SENDFILE_TYPE_TEXT){
        return @"文本";
    }else if (self.type == SENDFILE_TYPE_FILEINFOLIST){
        return @"列表";
    }else{
        return @"";
    }
}

@end
