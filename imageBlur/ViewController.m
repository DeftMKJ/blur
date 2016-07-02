//
//  ViewController.m
//  imageBlur
//
//  Created by 宓珂璟 on 16/6/14.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "ViewController.h"
#import "MKJBlurViewController.h"

@interface ViewController ()


@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}
- (IBAction)click:(id)sender {
    MKJBlurViewController *mkj = [[MKJBlurViewController alloc] init];
    [self.navigationController pushViewController:mkj animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
