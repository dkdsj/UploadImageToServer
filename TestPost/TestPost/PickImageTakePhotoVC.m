//
//  PickImageTakePhotoVC.m
//  TestPost
//
//  Created by 戴杨杨 on 2018/10/8.
//  Copyright © 2018年 sx. All rights reserved.
//

#import "PickImageTakePhotoVC.h"
#import <Photos/Photos.h>

#define UIAlertStyle (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet

@interface PickImageTakePhotoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *ivIcon;
@end

@implementation PickImageTakePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeHeadImage)];
    self.ivIcon.frame = CGRectMake(0, 200, 300, 270);
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)changeHeadImage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertStyle];
    UIAlertAction *actionp = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *actionx = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openPhotoLibrary];
    }];
    UIAlertAction *actionc = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionp];
    [alert addAction:actionx];
    [alert addAction:actionc];
    [self presentViewController:alert animated:YES completion:nil];
}

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

/**
 进入app设置页面
 */
- (void)openAppSettings {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        NSLog(@"无法打开设置");
    }
}

- (void)takePhoto {
    //判断相机是否可用
    if (![self isCameraAvailable]) {
        NSString *errorStr = @"您的设备不支持相机，将跳转到相册选择照片";
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:errorStr message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openPhotoLibrary];
            });
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        [alter addAction:action];
        [alter addAction:action1];
        [self presentViewController:alter animated:YES completion:nil];
        
        return;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"相机未授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openAppSettings];
            });
        }];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
        
        return;
    }
    
    // 照相机
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)openPhotoLibrary {
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
    
    // 判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    // 打开照片应用(显示所有相簿)
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 打开照片应用(只显示"时刻"这个相簿)
    //ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 设置图片
    self.ivIcon.image = info[UIImagePickerControllerOriginalImage];
}

- (UIImageView *)ivIcon {
    if (!_ivIcon) {
        _ivIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhifu"]];
        _ivIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_ivIcon];
    }
    
    return _ivIcon;
}
@end
