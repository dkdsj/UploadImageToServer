//
//  UploadHelper.h
//  TestPost
//
//  Created by 戴杨杨 on 2018/9/30.
//  Copyright © 2018年 sx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadHelper : NSObject

//fileName:随便取的名字
- (void)uploadPath:(NSString *)path
             param:(NSDictionary *)dict
          fileName:(NSString *)fileName
            result:(void (^)(id response))block;

@end
