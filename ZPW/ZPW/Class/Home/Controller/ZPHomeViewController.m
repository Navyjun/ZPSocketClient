//
//  ZPHomeViewController.m
//  ZPW
//
//  Created by 张海军 on 2017/11/1.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ZPHomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SocketManager.h"
#import "ZPHomeCell.h"
#import "HJWifiUtil.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "TZImageManager.h"

#import "NSString+path.h"

#import "TZVideoPlayerController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZPhotoPreviewController.h"

#import <VideoToolbox/VideoToolbox.h>

@interface ZPHomeViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
SocketManagerDelegate,
TZImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
/// 需要上传的资源数组
@property (nonatomic, strong) NSMutableArray *sendItemArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *connStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSendItem;

/// 是否需要刷新进度
@property (nonatomic, assign) BOOL needRefreshProgress;
/// 刷新当前网络名称
@property (nonatomic, weak) NSTimer *refreshTime;
/// 当前是否正在传输
@property (nonatomic, assign) BOOL isSending;
@end

@implementation ZPHomeViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"智屏快传";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClick)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"connect" style:UIBarButtonItemStyleDone target:self action:@selector(leftItemClick)];
    
    self.sendItemArray = [NSMutableArray array];
    self.tableView.rowHeight = 80;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    // 初始化话 socketManager
    SocketManager *manager = [SocketManager shareSocketManager];
    self.navigationItem.leftBarButtonItem.enabled = !manager.isConnect;
    manager.delegate = self;
    manager.connectStateBlock = ^(BOOL isConnect){
        self.connStateLabel.text = isConnect ? @"已连接" : @"已断开";
        self.navigationItem.leftBarButtonItem.enabled = !isConnect;
    };
    
    // 定时器
    self.refreshTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshWifiName) userInfo:nil repeats:YES];
    
    self.needRefreshProgress = YES;
    
    NSLog(@"wifiInfo = %@",[HJWifiUtil getLocalInfoForCurrentWiFi]);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshWifiName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - method
- (IBAction)sendButtonDidClick:(UIButton *)sender {
    // 提示 是否需要传输同一列表
    if ([[SocketManager shareSocketManager] listSendIsFinish]) {
        self.isSending = NO;
    }
    
    if (self.sendItemArray.count > 0) {
       self.isSending = YES;
       [self.tableView reloadData];
       [SocketManager shareSocketManager].needSendItems = self.sendItemArray;
    }
}


- (void)leftItemClick{
    SocketManager *socketM = [SocketManager shareSocketManager];
    [socketM connentHost:CURRENT_HOST prot:CURRENT_PORT];
}

- (void)rightItemDidClick{

    if ([[SocketManager shareSocketManager] listSendIsFinish]) {
        self.currentSendItem.text = @"";
        [SocketManager shareSocketManager].needSendItems = nil;
        [self.sendItemArray removeAllObjects];
        [self.tableView reloadData];
    }
    
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:100 columnNumber:4 delegate:self pushPhotoPickerVc:NO];
    imagePickerVc.allowTakePicture = YES; //内部显示拍照按钮
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingMultipleVideo = YES; // 是否可以多选视频
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)refreshWifiName{
    self.wifiNameLabel.text = [NSString stringWithFormat:@"当前连接wifi:%@",[HJWifiUtil fetchWiFiName]];
    //
    if (self.sendItemArray.count && ![[SocketManager shareSocketManager] listSendIsFinish]) {
        [self.tableView reloadData];
    }
}

//- (void)showMessage:()


#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    
    for (id objc in assets) {
        PHAsset *asset = (PHAsset*)objc;
        SockerSendItem *sendItem = [[SockerSendItem alloc] init];
        // 文件名称
        sendItem.fileName = [ZPPublicMethod getAssetsName:asset];
        // asset
        sendItem.asset = asset;
        // 获取缩略图
        [ZPPublicMethod getThumbnail:asset
                                size:CGSizeMake(45, 45)
                              result:^(UIImage *thumImage) {
                                  if (thumImage) {
                                      NSData *data = UIImagePNGRepresentation(thumImage);
                                      sendItem.thumImgPath = [sendItem.fileName tmpDir];
                                      BOOL isFinish = [data writeToFile:sendItem.thumImgPath atomically:YES];
                                      if (!isFinish) {
                                          [data writeToFile:sendItem.thumImgPath atomically:YES];
                                      }
                                  }
                              }];
        // 类型
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            sendItem.type = SENDFILE_TYPE_VIDEO;
        }else if (asset.mediaType == PHAssetMediaTypeImage){
            sendItem.type = SENDFILE_TYPE_IMAGE;
        }else if (asset.mediaType == PHAssetMediaTypeAudio){
            sendItem.type = SENDFILE_TYPE_AUDIO;
        }
        
        [self.sendItemArray addObject:sendItem];
        
        // 文件路径
        [ZPPublicMethod getfilePath:asset Complete:^(NSURL *fileUrl) {
            sendItem.fileSize = [ZPPublicMethod getFileSize:[[fileUrl absoluteString] substringFromIndex:8]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark - socketManagerDelegate
- (void)socketManager:(SocketManager *)manager itemUpingrefresh:(SockerSendItem *)upingItem{
    self.isSending = YES;
}

- (void)socketManager:(SocketManager *)manager itemUpFinishrefresh:(SockerSendItem *)finishItem{
    NSInteger totalCount = self.sendItemArray.count;
    if(finishItem.index == (totalCount -1)){
        self.currentSendItem.text = [NSString stringWithFormat:@"全部传完(%zd个)",self.sendItemArray.count];
        [self.tableView reloadData];
    }else if (finishItem.index < totalCount){
        self.currentSendItem.text = [NSString stringWithFormat:@"文件%zd传完",(finishItem.index+1)];
        [self.tableView reloadData];
    }
}


#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sendItemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZPHomeCell *cell = [ZPHomeCell homeCell:tableView];
    cell.dataItem = self.sendItemArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SockerSendItem *item = self.sendItemArray[indexPath.row];
    TZAssetModelMediaType type = TZAssetModelMediaTypePhoto;
    if (item.type == SENDFILE_TYPE_VIDEO) {
        type = TZAssetModelMediaTypeVideo;
    }
    TZAssetModel *assetM = [TZAssetModel modelWithAsset:item.asset type:type];
    [self pushFileDetaiVC:assetM index:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 整个列表传输完成 后可播放
    if ([[SocketManager shareSocketManager] listSendIsFinish]) {
        [[SocketManager shareSocketManager] sendPlayInstructions:item];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSending && ![[SocketManager shareSocketManager] listSendIsFinish]) {
        return NO;
    }
    return YES;
}
//设置处理编辑情况
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < self.sendItemArray.count) {
            [self.sendItemArray removeObjectAtIndex:indexPath.row];
            [[SocketManager shareSocketManager].needSendItems removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
    }];
    
    return @[removeAction];
}


#pragma mark - unit
- (void)pushFileDetaiVC:(TZAssetModel *)model index:(NSInteger)index {
    if (model.type == TZAssetModelMediaTypeVideo) {
        TZVideoPlayerController *videoPlayerVc = [[TZVideoPlayerController alloc] init];
        videoPlayerVc.model = model;
        [self presentViewController:videoPlayerVc animated:YES completion:nil];
    } else if (model.type == TZAssetModelMediaTypePhotoGif) {
        TZGifPhotoPreviewController *gifPreviewVc = [[TZGifPhotoPreviewController alloc] init];
        gifPreviewVc.model = model;
        [self presentViewController:gifPreviewVc animated:YES completion:nil];
    }else {
        NSMutableArray *assetArray = [NSMutableArray arrayWithObject:model.asset];
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:assetArray selectedPhotos:nil index:0];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}


@end
