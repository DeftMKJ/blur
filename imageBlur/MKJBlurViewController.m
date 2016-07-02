//
//  MKJBlurViewController.m
//  imageBlur
//
//  Created by 宓珂璟 on 16/6/14.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "MKJBlurViewController.h"
#import <Masonry.h>
#import <MXSegmentedPager.h>
#import "MKJChildViewController.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Blur.h"
#import <WebKit/WebKit.h>
#import "MXParallaxHeader.h"
#import "MXCustomView.h"
@interface MKJBlurViewController () <MXSegmentedPagerDelegate,MXSegmentedPagerDataSource,WKNavigationDelegate>

@property (nonatomic,strong) MXSegmentedPager *segmentedPager; //!< MX框架
@property (strong, nonatomic) IBOutlet UIView *headView; //!< 头部视图
@property (weak, nonatomic) IBOutlet UIImageView *blurImageView; //!< 头部模糊图片
@property (weak, nonatomic) IBOutlet UIImageView *nickImageView; //!< 头像

@property (nonatomic,strong) MKJChildViewController *firstChildVC; //!< 第一个对应的VC
@property (nonatomic,strong) WKWebView *webView; //!< webView
@property (nonatomic,strong) UIActivityIndicatorView *indicator; //!< 加载指示器
@property (nonatomic,strong) MXCustomView *customView;//!< 双TableView视图

@end

@implementation MKJBlurViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initIndicator];
    [self initVC];
    [self initHeadView];
    [self initMX];
}

// 加载指示器
- (void)initIndicator
{
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.webView addSubview:self.indicator];
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.webView);
        make.centerY.mas_equalTo(self.webView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        
    }];
}
// 加载头部模糊视图的图片和头像
- (void)initHeadView
{
    // 圆形头像无需模糊
    self.nickImageView.layer.cornerRadius = 25.0f;
    self.nickImageView.clipsToBounds = YES;
    self.nickImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.nickImageView.layer.borderWidth = 2.0f;
    __weak typeof(self)weakSelf = self;
    [self.nickImageView sd_setImageWithURL:[NSURL URLWithString:@"http://twt.img.iwala.net/touxiang/563846208921b.jpg"]
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && cacheType == SDImageCacheTypeNone) {
            [weakSelf.nickImageView setNeedsDisplay];
            weakSelf.nickImageView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
               
                weakSelf.nickImageView.alpha = 1.0f;
            }];
        }
        else
        {
            weakSelf.nickImageView.alpha = 1.0f;
        }
    }];
    
    
    // 背景做成模糊，方法已经在Demo里面了，大家可以下载去取，一个方法暴露，简单就能实现
    [self.blurImageView sd_setImageWithURL:[NSURL URLWithString:@"http://twt.img.iwala.net/touxiang/563846208921b.jpg"]
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
       [self.blurImageView setNeedsDisplay];
                                     
        // 模糊开始
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        // 模糊接口，参数越接近1越模糊，直接调用他就OK了
        UIImage *blurImage = [[UIImage imageWithData:imageData] blurredImage:0.15f];
                                     
        weakSelf.blurImageView.image = blurImage;
        if (image && cacheType == SDImageCacheTypeNone) {
            weakSelf.blurImageView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
               
                weakSelf.blurImageView.alpha = 1.0f;
                
            }];
        }
        else
        {
            weakSelf.blurImageView.alpha = 1.0f;
        }
        
    }];
    [self.headView layoutSubviews];
}
// 初始化MX框架控制器，头部和选择栏
- (void)initMX
{
    // 头部
    self.segmentedPager = [[MXSegmentedPager alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.segmentedPager.parallaxHeader.view = self.headView; // 注意这里加载平行头部
    // MXParallaxHeaderModeCenter MXParallaxHeaderModeCenter MXParallaxHeaderModeTop  MXParallaxHeaderModeBottom四个，大家可以自己测试
    self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeFill; // 平行头部填充模式
    self.segmentedPager.parallaxHeader.height = 240; // 头部高度
    self.segmentedPager.parallaxHeader.minimumHeight = 64; // 头部最小高度
    
    // 选择栏控制器属性
    self.segmentedPager.segmentedControl.borderWidth = 1.0; // 边框宽度
    self.segmentedPager.segmentedControl.borderColor = [UIColor redColor]; // 边框颜色
    self.segmentedPager.segmentedControl.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44); // frame
    self.segmentedPager.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);// 间距
    self.segmentedPager.segmentedControl.selectionIndicatorHeight = 0;// 底部是否需要横条指示器，0的话就没有了，如图所示
    // 底部指示器的宽度是否根据内容
    self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    //HMSegmentedControlSelectionIndicatorLocationNone 不需要底部滑动指示器
    self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedPager.segmentedControl.verticalDividerEnabled = NO;// 不可以垂直滚动
    // fix的枚举说明宽度是适应屏幕的，不会根据字体   HMSegmentedControlSegmentWidthStyleDynamic则是字体多大就多宽
    self.segmentedPager.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    
    // 默认状态的字体
    self.segmentedPager.segmentedControl.titleTextAttributes =
                            @{NSForegroundColorAttributeName : [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1],
                                         NSFontAttributeName : [UIFont systemFontOfSize:14]};
    // 选择状态下的字体
    self.segmentedPager.segmentedControl.selectedTitleTextAttributes =
                                    @{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:174/255.0 blue:1 alpha:1],
                                                 NSFontAttributeName : [UIFont systemFontOfSize:18]};
    self.segmentedPager.segmentedControlEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.segmentedPager.delegate = self;
    self.segmentedPager.dataSource = self;
    [self.view addSubview:self.segmentedPager];
    [self.segmentedPager mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.view.mas_top).with.offset(0);
         make.left.equalTo(self.view.mas_left);
         make.bottom.equalTo(self.view.mas_bottom);
         make.right.equalTo(self.view.mas_right);
         make.width.equalTo(self.view.mas_width);
     }];
}

// 滚动整体的时候调用
- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didScrollWithParallaxHeader:(MXParallaxHeader *)parallaxHeader
{
    // 通过拿到滚动的对应的View
    UIScrollView *scrollView = (UIScrollView *)segmentedPager.subviews[0];
    NSLog(@"%lf",scrollView.contentOffset.y);
    // 计算alpha值
    CGFloat headAlpha = (1 - (-(scrollView.contentOffset.y + 64) / 136)) >= 0 ? (1 - (-(scrollView.contentOffset.y + 64) / 136)) : 0;
    self.headView.alpha = 1 - headAlpha;
    if (self.headView.alpha == 0)
    {
        self.navigationController.navigationBar.hidden = NO;
    }
    else
    {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)initVC
{
    if (!_firstChildVC) {
        _firstChildVC = [[MKJChildViewController alloc] initWithNumber:@"第一页"];
    }
}

#pragma -mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager
{
    // 指示栏的高度
    return 44.0f;
}

#pragma -mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager
{
    // 需要多少个界面
    return 3;
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index
{
    // 指示栏的文字数组
    return [@[@"控制器界面", @"WKWebView",@"双TableView"] objectAtIndex:index];
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index
{
    // 第一个是控制器的View 第二个是WebView  第三个是自定义的View 这个也是最关键的，通过懒加载把对应控制的初始化View加载到框架上面去
    return [@[self.firstChildVC.view, self.webView, self.customView] objectAtIndex:index];
}

- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.csdn.net/deft_mkjing/article/details/51730477"]]];
        _webView.navigationDelegate = self;
        
    }
    return _webView;
}
- (MXCustomView *)customView {
    if (!_customView) {
        _customView = [[MXCustomView alloc] init];
    }
    return _customView;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.indicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    
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
