//
//  FiledownVC.m
//  TestPost
//
//  Created by 戴杨杨 on 2018/10/10.
//  Copyright © 2018年 sx. All rights reserved.
//

#import "FiledownVC.h"
#import "SCSessionDownloadManager.h"
#import "GifItem.h"
#import "AFNetworking.h"

#define kDownDocument [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"SCDownloadFiles"]

#define kSafeStr(param) [NSString stringWithFormat:@"%@", param]
#define kPngStr(param) [NSString stringWithFormat:@"%@.png", param]
#define kGifStr(param) [NSString stringWithFormat:@"%@.gif", param]

@interface FiledownVC ()<SCSessionDownloadManagerDelegate>
//用来保存成功数据的数组
@property (strong, nonatomic) NSMutableArray *finishs;

@property (nonatomic, strong) NSArray *gifts;
@end

@implementation FiledownVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    
    UIBarButtonItem *bd = [[UIBarButtonItem alloc] initWithTitle:@"down" style:(UIBarButtonItemStyleDone) target:self action:@selector(downAllFiles)];
     UIBarButtonItem *bc = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:(UIBarButtonItemStyleDone) target:self action:@selector(cancelAll)];
    self.navigationItem.rightBarButtonItems = @[bc, bd];
}

- (void)initData {
    self.finishs = [NSMutableArray array];
    self.gifts = [NSArray array];
    
    [self getGifts];
}

//
- (void)getGifts {
    NSString *path = @"https://zbaz.shangxian.net:9001/live/liveGiftList";
    AFHTTPSessionManager *sm = [AFHTTPSessionManager manager];
    [sm GET:path parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *array = [NSArray array];
        
        if ([responseObject[@"resultCode"] intValue] == 0) {
            array = responseObject[@"result"];
        }
        
        for (NSDictionary *dic in array) {
            GifItem *item = [GifItem new];
            [item setValuesForKeysWithDictionary:dic];

            [tmp addObject:item];
        }
        
        self.gifts = tmp;
        
        //[self downAllFiles];
        NSLog(@"self.gifts:%@", self.gifts);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error.description);
    }];
}

- (void)cancelAll {
    SCSessionDownloadManager *dm = [SCSessionDownloadManager sharedSessionDownloadManager];
    [dm cancelAllFilesDownload];
}

- (void)downAllFiles {
    //首次点击依次添加到下载队列，以后就是全部暂停/全部开始切换
    SCSessionDownloadManager *dm = [SCSessionDownloadManager sharedSessionDownloadManager];
    dm.delegate = self;

    for (GifItem *item in self.gifts) {
        [dm addDownloadWithFileId:kSafeStr(item.giftId)
                          fileUrl:item.picAddress
                    directoryPath:kDownDocument
                         fileName:kPngStr(item.title)];
    }
    for (GifItem *item in self.gifts) {
        [dm addDownloadWithFileId:kSafeStr(item.giftId)
                          fileUrl:item.gifAddress
                    directoryPath:kDownDocument
                         fileName:kGifStr(item.title)];
    }
}

#pragma mark - SCSessionDownloadManagerDelegate

- (void)sessionDownloadManagerStartDownload:(SCSessionDownload *)download {}

- (void)sessionDownloadManagerUpdateProgress:(SCSessionDownload *)download
                                didWriteData:(uint64_t)writeLength
                                    fileSize:(uint64_t)totalLength
                               downloadSpeed:(NSString *)downloadSpeed {}

- (void)sessionDownloadManagerFinishDownload:(SCSessionDownload *)download
                                     success:(BOOL)downloadSuccess
                                       error:(NSError *)error
{
    if(downloadSuccess){
        [self.finishs addObject:download.fileId];
        NSLog(@"下了一个");
    }
    
    if (self.finishs.count == 2*self.gifts.count) {
        NSLog(@"全部下完了, \n%@", kDownDocument);
    }
}

@end
