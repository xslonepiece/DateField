//
//  ViewController.m
//  DateField
//
//  Created by Onepiece on 2019/3/29.
//  Copyright © 2019 Onepiece. All rights reserved.
//

#import "ViewController.h"
#import "DateField.h"

@interface ViewController ()

@property (nonatomic,weak)IBOutlet DateField *dateField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dateField setErrorHandle:^{
        [self alertMsg:@"输入日期格式有误！"];
    }];
   
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)]];
}

- (void)tap{
    [self.view endEditing:YES];
}

- (void)alertMsg:(NSString *)msg{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];

}


@end
