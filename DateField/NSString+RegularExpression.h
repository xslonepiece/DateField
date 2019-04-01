//
//  NSString+RegularExpression.h
//  DateField
//
//  Created by Onepiece on 2019/3/29.
//  Copyright © 2019 Onepiece. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (RegularExpression)

/**
 检查是否合法数字
 */
+ (BOOL)validateNumber:(NSString *)number;

@end

NS_ASSUME_NONNULL_END
