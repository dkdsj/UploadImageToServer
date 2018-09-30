//
//  UploadHelper.m
//  TestPost
//
//  Created by 戴杨杨 on 2018/9/30.
//  Copyright © 2018年 sx. All rights reserved.
//

#import "UploadHelper.h"

#define kBoundary @"------------0x0x0x0x0x0x0x0x"
#define IMAGE_CONTENT  @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define DATA(X)    [X dataUsingEncoding:NSUTF8StringEncoding]
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@implementation UploadHelper

- (void)uploadPath:(NSString *)path
             param:(NSDictionary *)dict
          fileName:(NSString *)fileName
            result:(void (^)(id response))block {
    //
    NSData *postData = [self prepareData:dict fileName:(NSString *)fileName];
    
    //
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    //[urlRequest setHTTPBody:postData];//在session传data就注释, session传request就设置body
    
    //
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    [[session uploadTaskWithRequest:urlRequest fromData:postData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //
        NSLog(@"%@\ndata:%@\n rsp:%@ err:%@", [NSThread currentThread], data, response, error.description);
        NSString *outstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"outstring:%@", outstring);
        
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(response);
            }
        });        
    }] resume];
}

//打包数据
- (NSData *)prepareData:(NSDictionary*)dict fileName:(NSString *)fileName {
    NSArray *keys = [dict allKeys];
    NSMutableData *result = [NSMutableData data];
    
    for (int i = 0; i < [keys count]; i++) {
        id value = dict[keys[i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]]) {
            // handle image data
            NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, keys[i], fileName];
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

@end
