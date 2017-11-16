//
//  ZPHomeCell.m
//  ZPW
//
//  Created by 张海军 on 2017/11/2.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ZPHomeCell.h"

#import <UIImageView+WebCache.h>

static NSString *NIBNAME = @"ZPHomeCell";

@implementation ZPHomeCell

+ (instancetype)homeCell:(UITableView *)tableView{
    ZPHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NIBNAME owner:nil options:nil][0];
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
    }
    return cell;
}

- (void)setDataItem:(SockerSendItem *)dataItem{
    _dataItem = dataItem;
    // video 图片标识
    if ([dataItem.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = (PHAsset *)dataItem.asset;
        self.videoTypeImage.hidden = asset.mediaType == PHAssetMediaTypeVideo ? NO : YES;
    }
    
    [self.fileImageView sd_setImageWithURL:[NSURL fileURLWithPath:dataItem.thumImgPath] placeholderImage:[UIImage imageNamed:@"背景图片_ico"]];
    if (self.dataItem.isSending || self.dataItem.isSendFinish){
        self.cancleButton.hidden = YES;
    }else{
        self.cancleButton.hidden = NO;
        self.cancleButton.enabled = !dataItem.isCancleSend;
    }
    
    self.fileNameLable.text = dataItem.fileName;
    self.fileTypeLabel.text = dataItem.typeStr;
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%0.2fM",(dataItem.fileSize * 1.0 / 1024.0 / 1024.0)];
    if (dataItem.isSending) {
        self.upProgressLabel.hidden = NO;
        self.upProgressLabel.text = [NSString stringWithFormat:@"%.2f%%",(1.0 * dataItem.upSize / dataItem.fileSize) * 100];
    }else{
        self.upProgressLabel.text = nil;
        self.upProgressLabel.hidden = YES;
    }
    if (dataItem.isSendFinish) {
        self.upProgressLabel.hidden = NO;
        self.upProgressLabel.text = @"100%";
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cancleButtonDidClick:(UIButton *)sender {
    if (!self.dataItem.isSending && !self.dataItem.isSendFinish && sender.isEnabled) {
        self.dataItem.isCancleSend = YES;
        sender.enabled = NO;
    }
}

@end
