//
//  SPProvince.m
//  SPPickerView
//
//  Created by develop1 on 2018/8/24.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "SPProvince.h"
#import "SPCity.h"

@implementation SPProvince
- (void)setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"children"]) {
        NSMutableArray *cities = [NSMutableArray array];
        for (NSDictionary *dict in value) {
            SPCity *city = [[SPCity alloc] init];
            [city setValuesForKeysWithDictionary:dict];
            [cities addObject:city];
        }
        self.children = cities;
    } else {
        [super setValue:value forKey:key];
    }

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

@end
