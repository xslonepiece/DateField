//
//  DateField.m
//  POS
//
//  Created by Onepiece on 2019/3/28.
//  Copyright © 2019 Onepiece. All rights reserved.
//

#import "DateField.h"
#import "NSString+RegularExpression.h"

static NSString *zero = @"0";
static NSString *hl = @"-";
static NSString *dateFormat = @"yyyy-MM-dd";
static NSInteger dateLength = 10;

@interface DateField ()<UITextFieldDelegate>

@property(nonatomic,copy)NSString *lastText;
@property(nonatomic,copy)NSString *replacementString;
@property(nonatomic)NSRange range;

@end

@implementation DateField

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [self limitDateValueTextField:textField shouldChangeCharactersInRange:range replacementString:string];
}

- (void)textFieldValueChanged:(NSNotification *)noti{
    if (noti.object != self) {
        return;
    }
    self.text = [self autoCompleteInput:self.text];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    textField.text = [self completeText:textField.text];
    // 校验日期格式
    [self validDate:textField.text];
    return YES;
}

- (BOOL)validDate:(NSString *)string{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSDate *date = [formatter dateFromString:string];
    if (date == nil) {
        if (self.errorHandle) {
            self.errorHandle();
        }
        return NO;
    }
    if (self.validateHandle) {
        if(!self.validateHandle(string)){
            if (self.errorHandle) {
                self.errorHandle();
            }
            return NO;
        };
    }
    return YES;
}

/**
 收键盘再补全一次
 因为autoCompleteInput方法，是实时输入的，所以在2018-03-3时，（因为不知道用户是否要输入“2018-03-3*”）不补零。
 so 在收键盘时，需要将2018-03-3 => 2018-03-03
 */
- (NSString *)completeText:(NSString *)text{
    if (text.length < dateLength - 1) {
        text = [self autoCompleteInput:text];
    }
    if (text.length == dateLength - 1) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(dateLength - 2, 0) withString:zero];
    }
    return text;
}

/**
 输入时自动补全"0"&"-"
 
 输入内容正则限定：“^[1-2][0-9]{0,3}\\-{0,1}[0-9]{0,2}\\-{0,1}[0-9]{0,2}” yyyy(-)MM(-)dd
 input:
 2018-1-5
 2018-95
 201812
 20181-2
 */
- (NSString *)autoCompleteInput:(NSString *)input{
    NSInteger monIdx = 4;
    input = [self autoCompleteZero:input focusIdx:&monIdx max:12];// 月份补0
    NSInteger dayIdx = monIdx + 2;
    input = [self autoCompleteZero:input focusIdx:&dayIdx max:31];// 日期补0
    input = [self autoCompleteHl:input atIdx:4];    // 年月中补“-”
    input = [self autoCompleteHl:input atIdx:7];    // 月日中补"-"
    return input;
}

- (NSString *)autoCompleteHl:(NSString *)input atIdx:(NSInteger)idx{
    if (idx < input.length) {
        NSString *ch = [input substringWithRange:NSMakeRange(idx, 1)];
        if ([NSString validateNumber:ch]) {
            input = [input stringByReplacingCharactersInRange:NSMakeRange(idx, 0) withString:hl];
        }
    }
    return input;
}

/**-
 自动补零：用于日期输入补零，主要是月份，日期补0.（仅适用于两位数补0）
 
 @param input 输入字符串
 @param idx 焦点下标：月份/日期开始下标
 @param max 最大值 日期时31，月份时12
 @return 返回补零后字符串
 */
- (NSString *)autoCompleteZero:(NSString *)input focusIdx:(NSInteger *)idx max:(NSInteger)max{
    if (input.length <= *idx) return input;//  如果长度小于等于monIdx，不需要补齐
    NSString *ch = [input substringWithRange:NSMakeRange(*idx, 1)];
    if (![NSString validateNumber:ch]) {// 如果该位为不为数字，认为是分隔符，往后走一位
        (*idx)++;
    }
    if (input.length <= *idx) return input;
    
    ch = [input substringWithRange:NSMakeRange(*idx, 1)];
    if(*idx + 1 < input.length){// 下一个字符为“-”,补0 下一个字符为数字，判断两数是否合法月份，否则补0
        NSString *nch = [input substringWithRange:NSMakeRange(*idx + 1, 1)];
        if (![NSString validateNumber:nch]) {
            input = [input stringByReplacingCharactersInRange:NSMakeRange(*idx, 0) withString:zero];
        }else{
            NSString *mon = [input substringWithRange:NSMakeRange(*idx, 2)];
            if(max < mon.integerValue){
                input = [input stringByReplacingCharactersInRange:NSMakeRange(*idx, 0) withString:zero];
            }
        }
    }else if (ch.integerValue > max / 10) {// 月份大于1时，代表是2-9月，需要补零
        input = [input stringByReplacingCharactersInRange:NSMakeRange(*idx, 0) withString:zero];
    }
    return input;
}

/**
 日期格式 1990-12-20
 */
- (BOOL)limitDateValueTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.range = range;
    self.lastText = textField.text;
    self.replacementString = string;
    if (!string || string.length == 0) { // 允许删
        return YES;
    }
    BOOL inputCheck = ([string rangeOfString:@"^[0-9\\-]+" options:NSRegularExpressionSearch].location != NSNotFound);
    if (!inputCheck)     return NO;
    NSString *regex = @"^[1-2][0-9]{0,3}\\-{0,1}[0-9]{0,2}\\-{0,1}[0-9]{0,2}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    NSString *afterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    bool valid = [predicate evaluateWithObject:afterText];
    if (!valid) return NO;
    NSString *subRegex = nil;// 分段正则表达式
    if (afterText.length >= 10) {// 判断是否合法日期格式且00<dd<=31
        subRegex = @"^(1[0-9]|20)[0-9]{2}\\-(0[1-9]|1[0-2])\\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])";
    }else if (afterText.length >= 7){
        // 判断是否合法月份00<MM<=12：因为自动补全功能，月份输入24时，会自动区分为02-04，因此月份不会大于12  否则分段点“7”存在问题
        subRegex = @"^(1[0-9]|20)[0-9]{2}\\-{0,1}(0[1-9]|1[0-2]|[1-9])\\-{0,1}[0-9]{0,2}";
    }else if (afterText.length >= 2){// 判断是否合法yyyy-...
        subRegex = @"^(1[0-9]|20)[0-9]{0,2}\\-{0,1}[0-9]*";
    }
    if (subRegex && subRegex.length > 0) {
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", subRegex];
        valid = [predicate evaluateWithObject:afterText];
    }
    return valid;
}

@end
