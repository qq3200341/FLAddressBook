//
//  NSString+Helper.m
//  FLAddressBookDemo
//
//  Created by qq3200341 on 16/8/25.
//  Copyright © 2016年 maipu. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)
/**
 *  获取字符串拼音
 *
 *  @return <#return value description#>
 */
- (NSString *)pinyin
{
    if (self.length)
    {
        NSMutableString *ms = [[NSMutableString alloc] initWithString:self];
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO))
        {
            //带音调
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO))
            {
                //不带音调
                return [ms uppercaseString];
            }
        }
        
    }
    return nil;
}
@end
