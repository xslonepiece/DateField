//
//  DateField.h
//  POS
//
//  Created by Onepiece on 2019/3/28.
//  Copyright © 2019 Onepiece. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateField : UITextField

@property (nonatomic,strong)void (^errorHandle)(void);
@property (nonatomic,strong)BOOL (^validateHandle)(NSString *text);


@end

NS_ASSUME_NONNULL_END
