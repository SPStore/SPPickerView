//
//  SPProvince.h
//  SPPickerView
//
//  Created by develop1 on 2018/8/24.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPLocation;

@interface SPProvince : NSObject
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSArray *cidx;
@property (nonatomic, copy) NSString *fullname;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, strong) SPLocation *location;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *pinyin;
@end
