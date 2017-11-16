//
//  ZPHomeCell.h
//  ZPW
//
//  Created by 张海军 on 2017/11/2.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SockerSendItem.h"

@interface ZPHomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLable;
@property (weak, nonatomic) IBOutlet UILabel *fileTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *upProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
/// 回调刷新
@property (nonatomic, copy) void(^refreshBlock)();
/// 模型数据
@property (nonatomic, strong) SockerSendItem *dataItem;
+ (instancetype)homeCell:(UITableView *)tableView;
@end
