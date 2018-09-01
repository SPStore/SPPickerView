//
//  SPCity.m
//  SPPickerView
//
//  Created by develop1 on 2018/8/24.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "SPCity.h"
#import "SPDistrict.h"

@implementation SPCity
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"children"]) {
        NSMutableArray *districts = [NSMutableArray array];
        for (NSDictionary *dict in value) {
            SPDistrict *district = [[SPDistrict alloc] init];
            [district setValuesForKeysWithDictionary:dict];
            [districts addObject:district];
        }
        self.children = districts;
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

@end
