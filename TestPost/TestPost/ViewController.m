//
//  ViewController.m
//  TestPost
//
//  Created by 戴杨杨 on 2018/9/12.
//  Copyright © 2018年 sx. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UploadHelper.h"
#import "PickImageTakePhotoVC.h"
#import "DownImagesVC.h"
#import "FLAnimatedImage.h"

NSString *baseURL = @"http://192.168.0.130:8000/app/uploadPictures";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *b1;
@property (weak, nonatomic) IBOutlet UIButton *b2;
@property (weak, nonatomic) IBOutlet UIButton *b3;
@property (weak, nonatomic) IBOutlet UIButton *b4;
@property (weak, nonatomic) IBOutlet UILabel *labelMsg;

- (IBAction)b1111:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"aa";
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(changeHeadImage)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(downImages)];
    
    [self initData];
}

//@"https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"
- (void)initData {
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://hjq-1257036536.cos.ap-shanghai.myqcloud.com/gift/520.gif"]]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
}

- (void)downImages {
    DownImagesVC *pp = [DownImagesVC new];
    [self.navigationController pushViewController:pp animated:YES];
}

- (void)changeHeadImage {
    PickImageTakePhotoVC *pp = [PickImageTakePhotoVC new];
    [self.navigationController pushViewController:pp animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray *imgArray = @[@"back4.jpg",@"bk_1.jpg",@"bk_3.jpg",@"bk_4.jpg",@"bk_5.jpg"];
    int x = arc4random()%imgArray.count;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imgArray[x]]];
    
    self.labelMsg.text = @"nit";
}

//上传头像图片到服务器
-(void) postImageToServer {
    self.labelMsg.text = @"init";
    
    AFHTTPSessionManager *_manager = [AFHTTPSessionManager manager] ;
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                          @"application/json",
                                                          @"text/html"       ,
                                                          @"image/jpeg"      ,
                                                          @"image/png"       ,
                                                          @"image/jpg"       ,
                                                          @"application/octet-stream",
                                                          @"text/json"      ,
                                                          nil] ;
    
    _manager.requestSerializer  = [AFHTTPRequestSerializer serializer ] ;
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer] ;
    
    [_manager POST:baseURL parameters:@{@"accountId":@"1"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         NSData *data = [@"1" dataUsingEncoding:NSUTF8StringEncoding] ;
         [formData appendPartWithFormData:data name:@"studentId"] ;
         
         //在网络开发中，上传文件时，文件是不允许被覆盖，文件重名
         //要解决此问题，可以在上传时使用当前的系统事件作为文件名
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
         
         //设置时间格式
         formatter.dateFormat = @"yyyyMMddHHmmss" ;
         NSString *str = [formatter stringFromDate:[NSDate date]] ;
         NSString *fileName = [NSString stringWithFormat:@"%@.jpg",str] ;
         
         //压缩图片
         //_imageEdit是从相机获取的图片
         NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"bk_3.jpg"], 0.1);
         
         //上传图片到服务器
         [formData appendPartWithFileData:imageData name:@"files" fileName:fileName mimeType:@"image/*"] ;
     }
     
     //上传过程中调用
          progress:^(NSProgress * _Nonnull uploadProgress)
     {
     }
     
     //上传成功调用
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSString *outstring = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"outstring:%@", outstring);
         self.labelMsg.text = outstring;
     }
           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"上传失败") ;
     }] ;
}



- (void)appendData1 {
    self.labelMsg.text = @"init";
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"bk_3.jpg"], 0);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//初始化请求对象
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置服务器允许的请求格式内容
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json", @"text/javascript,multipart/form-data", nil];
    
    //上传图片/文字，只能同POST
    [manager POST:baseURL parameters:@{@"accountId":@"1"} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 注意：这个name（我的后台给的字段是file）一定要和后台的参数字段一样 否则不成功
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"aaa.jpg" mimeType:@"image/jpg"];
        // [formData appendPartWithFormData:[@"wfWiEWrgEFA9A78512weF7106A" dataUsingEncoding:NSUTF8StringEncoding] name:@"aaa"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress = %@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *outstring = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"outstring:%@ responseObject = %@, task = %@", outstring,responseObject,task);
        self.labelMsg.text = outstring;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
}

//后台接口 /app/uploadPictures ---> Integer accountId, MultipartFile [] files
- (void)postWitdData {
    self.labelMsg.text = @"init";
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"bk_3.jpg"], 0);
    NSDictionary *param = @{@"accountId":@"1",
                            @"files":imageData,
                            };
    
    UploadHelper *uh = [UploadHelper new];
    [uh uploadPath:baseURL param:param fileName:@"abc.jpg" result:^(id response) {
        self.labelMsg.text = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    }];
}

- (void)pmdUpload {
    self.labelMsg.text = @"init";
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"bk_3.jpg"], 0);
    NSDictionary *param = @{@"accountId":@"1",
                            @"files":imageData,
                            @"fileName":@"background"
                            };
    
    [self uploadWithParam:param url:baseURL];
}

#define kBoundary @"------------0x0x0x0x0x0x0x0x"
#define IMAGE_CONTENT  @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define DATA(X)    [X dataUsingEncoding:NSUTF8StringEncoding]
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

- (void)uploadWithParam:(NSDictionary *)dict url:(NSString *)urlString {
    NSData *postData = [self prepareData:dict];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    //[urlRequest setHTTPBody:postData];//在session传data就注释, session传request就设置body
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    [[session uploadTaskWithRequest:urlRequest fromData:postData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@\ndata:%@\n rsp:%@ err:%@", [NSThread currentThread], data, response, error.description);
        
        NSString *outstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"outstring:%@", outstring);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelMsg.text = outstring;
        });
        
    }] resume];
}

- (NSData *)prepareData:(NSDictionary*)dict {
    NSArray *keys = [dict allKeys];
    NSMutableData *result = [NSMutableData data];
    
    for (int i = 0; i < [keys count]; i++) {
        id value = dict[keys[i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]]) {
            // handle image data
            NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, keys[i], dict[@"fileName"]];
            [result appendData: DATA(formstring)];
            [result appendData:value];
        } else {
            // all non-image fields assumed to be strings
            NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, keys[i]];
            [result appendData: DATA(formstring)];
            [result appendData:DATA(value)];
        }
        
        NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
    
    NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", kBoundary];
    [result appendData:DATA(formstring)];
    return result;
}


- (IBAction)b1111:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self postImageToServer];
            break;
        case 2:
            [self appendData1];
            break;
        case 3:
            [self postWitdData];
            break;
        case 4:
            [self pmdUpload];
            break;
        default:
            break;
    }
}

@end
