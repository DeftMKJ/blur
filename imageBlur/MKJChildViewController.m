//
//  MKJChildViewController.m
//  imageBlur
//
//  Created by 宓珂璟 on 16/6/14.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "MKJChildViewController.h"
#import <UIImageView+WebCache.h>

@interface MKJChildViewController ()
@property (nonatomic,copy) NSString *number;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MKJChildViewController

- (instancetype)initWithNumber:(NSString *)number
{
    self = [super init];
    if (self) {
        self.number = number;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self)weakSelf = self;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://twt.img.iwala.net/touxiang/56384645480d8.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && cacheType == SDImageCacheTypeNone) {
            weakSelf.imageView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
               
                weakSelf.imageView.alpha = 1.0f;
                
            }];
        }
        else
        {
            weakSelf.imageView.alpha = 1.0f;
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
