//
//  DownImagesVC.m
//  TestPost
//
//  Created by 戴杨杨 on 2018/10/8.
//  Copyright © 2018年 sx. All rights reserved.
//

#import "DownImagesVC.h"
#import "SDWebImageManager.h"
#import <Photos/Photos.h>
#import "FLAnimatedImage.h"

#define kGiftListFilePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GiftList.plist"]

@interface DownImagesVC ()
@property (nonatomic, strong) NSData *passImgData;
@end

@implementation DownImagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(download)];

}

- (void)download {
    NSArray *imageURLs = @[@"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/520_p.png",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/666_p.png",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/car_p.png",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/kiss_p.png",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/rocket_p.png",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/520.gif",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/666.gif",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/car.gif",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/kiss.gif",
                           @"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/rocket.gif"];
    [self myDownload:imageURLs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initData];
}

- (void)initData {
    //获取授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请您设置允许该应用访问您的相机\n设置>隐私>相机" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openAppSettings];
            });
        }];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
        
        return;
    }
    
    //请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");
        }else{
            NSLog(@"Denied or Restricted");
            //----为什么没有在这个里面进行权限判断，因为会项目会蹦。。。
        }
    }];
}

/**
 进入app设置页面
 */
- (void)openAppSettings {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        NSLog(@"无法打开设置");
    }
}
- (void)showPng {
    NSArray *imgs = [NSArray arrayWithContentsOfFile:kGiftListFilePath];
    
    for (int i = 0; i < imgs.count; i++) {
        NSDictionary *dic = imgs[i];
        
        NSString *fileName = [NSString stringWithFormat:@"%@", dic.allKeys.firstObject];
        if ([fileName hasSuffix:@"png"]) {
            NSData *data = dic[fileName];
            
            UIButton *btnImg = [[UIButton alloc] initWithFrame:CGRectMake(0, (i+1)*100, 100, 60)];
            UIImage *image = [UIImage imageWithData:data];
            [btnImg setBackgroundImage:image forState:UIControlStateNormal];
            [btnImg addTarget:self action:@selector(showGif:) forControlEvents:UIControlEventTouchUpInside];
            btnImg.tag = i;
            [self.view addSubview:btnImg];
        }
    }
}

- (void)showGif:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSArray *imgs = [NSArray arrayWithContentsOfFile:kGiftListFilePath];
    
    NSDictionary *des = imgs[tag];
    
    NSString *fileName = @"9696969";
    //找到点击的图片名称
    for (NSDictionary *dic in imgs) {
        if ([dic.allKeys.firstObject isEqualToString:des.allKeys.firstObject]) {
            fileName = [NSString stringWithFormat:@"%@", dic.allKeys.firstObject];//520.png
            fileName = fileName.stringByDeletingPathExtension;//520
            fileName = [fileName stringByAppendingPathExtension:@"gif"];//520.gif
            
            break;
        }
    }
    
    //not found
    if ([fileName isEqualToString:@"9696969"]) {
        return;
    }
    
    //找到图片对应的gif
    for (NSDictionary *dic in imgs) {
        NSLog(@"imageName:%@", dic.allKeys.firstObject);
        if ([dic.allKeys.firstObject isEqualToString:fileName]) {//520.gif
            self.passImgData = dic[fileName];
            break;
        }
    }
    
    //not found
    if (!self.passImgData) {
        return;
    }

    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:self.passImgData];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = self.view.bounds;
    [UIApplication.sharedApplication.keyWindow addSubview:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

- (void)myDownload:(NSArray *)urls {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *imageDics = [NSMutableArray array];
        
        for (int i = 0; i < urls.count; i++) {
            NSString *path = urls[i];
            
            [[session dataTaskWithURL:[NSURL URLWithString:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
#if 0
                    if ([path hasSuffix:@"gif"]) {
                        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
                        imageView.animatedImage = image;
                        imageView.frame = CGRectMake(0, i++*60, 100, 60);
                        [self.view addSubview:imageView];
                    }
                    else {
                        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, i++*60, 100, 60)];
                        iv.image = [UIImage imageWithData:data];
                        [self.view addSubview:iv];
                    }
#else
                    //path.lastPathComponent 520_p.png,520.gif
                    NSString *fileName = @"";
                    if ([path hasSuffix:@"gif"]) {
                        fileName = path.lastPathComponent;
                    }
                    else {//->520.png
                        NSString *pathExt = path.lastPathComponent.pathExtension;
                        fileName = path.lastPathComponent.stringByDeletingPathExtension;
                        fileName = [fileName substringToIndex:fileName.length-2];
                        fileName = [fileName stringByAppendingPathExtension:pathExt];
                        NSLog(@"down--fileName:%@", fileName);
                    }
                    
                    NSDictionary *dic = @{fileName:data};
                    NSLog(@"addObj:%@", dic.allKeys.firstObject);
                    [imageDics addObject:dic];
                    if (imageDics.count == urls.count) {
                        NSLog(@"gif下载完毕========");
                        [imageDics writeToFile:kGiftListFilePath atomically:YES];
                        [self showPng];
                    }
#endif
                });
            }] resume];
        }
    });
}

- (void)downloadImages:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock {
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    manager.downloadTimeout = 20;
    __block NSMutableDictionary *resultDict = [NSMutableDictionary new];
    for (int i = 0; i < imgsArray.count; i++) {
        [manager downloadImageWithURL:[NSURL URLWithString:imgsArray[i]]
                              options:SDWebImageDownloaderUseNSURLCache|SDWebImageDownloaderScaleDownLargeImages
                             progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {}
                            completed:^(UIImage * image, NSData *data, NSError * error, BOOL finished) {
                                if(finished) {
                                    if(error) {
                                        //在对应的位置放一个error对象
                                        [resultDict setObject:error forKey:@(i)];
                                    } else{
                                        [resultDict setObject:image forKey:@(i)];
                                        
                                        [self saveImageFinished:image];
                                    }
                                    
                                    if(resultDict.count == imgsArray.count) {
                                        //全部下载完成
                                        if(completionBlock){
                                            completionBlock(@[]);
                                        }
                                    }
                                }
                            }];
    }
}
- (void)saveImageFinished:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
