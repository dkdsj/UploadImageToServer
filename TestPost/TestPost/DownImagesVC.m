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

@interface DownImagesVC ()

@end

@implementation DownImagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
    //[self downloadImages:imageURLs completion:nil];
}

- (void)myDownload:(NSArray *)urls {
//    for (NSString *path in urls) {
//        dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
//    }
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
