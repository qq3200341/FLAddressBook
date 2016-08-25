//
//  ViewController.m
//  FLAddressBookDemo
//
//  Created by qq3200341 on 16/8/25.
//  Copyright © 2016年 maipu. All rights reserved.
//

#import "ViewController.h"
#import "FLAddressBookVC.h"

@interface ViewController ()<FLAddressBookVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addressBookBtnClick:(id)sender
{
    FLAddressBookVC *fvc = [[FLAddressBookVC alloc] init];
    fvc.delegate = self;
    [self.navigationController pushViewController:fvc animated:YES];
}

#pragma mark--FLAddressBookVCDelegate
- (void)phoneAddressBookVC:(FLAddressBookVC *)pabvc didSelectRowWithLinkMan:(LinkMan *)linkMan
{
    NSLog(@"选中的联系人：%@", linkMan);
}
@end
