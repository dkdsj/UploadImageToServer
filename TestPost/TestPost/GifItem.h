//
//  GifItem.h
//  Living
//
//  Created by 戴杨杨 on 2018/10/8.
//  Copyright © 2018年 sx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifItem : NSObject

@property (nonatomic , strong) NSString * gmtCreated;
@property (nonatomic , strong) NSString * gifAddress;
@property (nonatomic , strong) NSNumber * giftId;
@property (nonatomic , strong) NSNumber * price;
@property (nonatomic , strong) NSString * title;
@property (nonatomic , strong) NSString * picAddress;
@property (nonatomic , strong) NSNumber * isDel;

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end
