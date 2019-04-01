//
//  NSString+RegularExpression.m
//  DateField
//
//  Created by Onepiece on 2019/3/29.
//  Copyright © 2019 Onepiece. All rights reserved.
//

#import "NSString+RegularExpression.h"

@implementation NSString (RegularExpression)

/**
 检查是否合法数字
 */
+ (BOOL)validateNumber:(NSString *)number{
    NSString *pwdRegex = @"[0-9]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pwdRegex];
    return [predicate evaluateWithObject:number];
}

@end
