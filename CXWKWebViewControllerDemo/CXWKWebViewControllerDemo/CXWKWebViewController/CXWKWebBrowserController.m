//
//  CXWKWebBrowserController.m
//  CXWKWebViewControllerDemo
//
//  Created by Xu Chen on 2018/12/4.
//  Copyright © 2018 xu.yzl. All rights reserved.
//

#import "CXWKWebBrowserController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>

@interface CXWKWebBrowserController ()<WKUIDelegate,WKNavigationDelegate>
/*! 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/*! 进度条 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/*! 更多按钮 */
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
/*! 关闭按钮 */
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
/*! 自定义导航高度约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customNavbarHeightCons;

/*! 网页 */
@property (nonatomic, strong) WKWebView *wkWebView;
/*! 导航栏高度（适配 iPhone X ） */
@property (nonatomic, assign) CGFloat navgationBarHeight;
/*! 链接地址 */
@property (nonatomic, strong) NSString *urlString;

@end

@implementation CXWKWebBrowserController

#pragma mark - **************** 移除监听

- (void)dealloc {
    // 移除监听
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.wkWebView removeObserver:self forKeyPath:@"title" context:nil];
    
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 适配 iPhone X
        self.navgationBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height + 44.f;
        self.customNavbarHeightCons.constant = self.navgationBarHeight;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavbarHeightCons.constant = self.navgationBarHeight;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

/**
 获取当前 Controller 对象
 */
+ (instancetype)cx_loadWkWebViewWithUrlString:(NSString *)urlString {
    CXWKWebBrowserController *vc = [[CXWKWebBrowserController alloc] initWithNibName:@"CXWKWebBrowserController" bundle:nil];
    vc.urlString = urlString;
    [vc startLoadWebView];
    return vc;
}

/**
 加载网页
 */
- (void)startLoadWebView {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [self.wkWebView loadRequest:urlRequest];
    [self.view addSubview:self.wkWebView];
}

/**
 监听网页加载进度
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    //NSLog(@"进度%f",self.wkWebView.estimatedProgress)
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) { // 进度
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) { // 标题
        // 设置自定义导航栏的标题
        self.titleLabel.text = change[@"new"];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// MARK: - WKNavigationDelegate

/**
 网页开始加载回调方法
 */
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    // 显示状态栏网络加载菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // 开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
}

/**
 网页加载完成回调方法
 */
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 隐藏状态栏网络加载菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // 缩放
    [self changeWebViewZoom:webView];
    // 禁止长按弹出选择框
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:^(id object, NSError * error) {}];
}

/**
 网页加载失败回调方法
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    // 隐藏状态栏网络加载菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.titleLabel.text = @"网页加载失败";
}

/**
 网页即将白屏的回调方法
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    // 解决白屏问题
    [webView reload];
}

/**
 注入js,控制网页的缩放效果
 
 js代码中：user-scalable=yes:表示可以通过手势捏合缩放， user-scalable=no:表示禁止缩放
 */
- (void)changeWebViewZoom:(WKWebView *)webView {
    NSString *injectionJSString = @"var script = document.createElement('meta');" "script.name = 'viewport';" "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=3, minimum-scale=.5, user-scalable=yes\";" "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

/**
 如果不添加这个，那么wkwebview跳转不了AppStore ？
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL]; decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


// MARK: - 响应事件

/**
 返回
 */
- (IBAction)backButtonClicked:(UIButton *)sender {
    if([self.wkWebView canGoBack]){
        [self.wkWebView goBack];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 关闭
 */
- (IBAction)closeButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 更多
 */
- (IBAction)moreButtonClicked:(id)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"更多" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *safariAlertAction = [UIAlertAction actionWithTitle:@"safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.urlString && (self.urlString.length > 0)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
        } else {
            NSLog(@"无法获取到当前 URL！");
            [self showSystemAlert:@"无法获取到当前 URL！"];
        }
    }];
    UIAlertAction *copyAlertAction = [UIAlertAction actionWithTitle:@"复制链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.urlString.length > 0) {
            [[UIPasteboard generalPasteboard] setString:self.urlString];
            NSLog(@"已复制URL到黏贴板中！");
            [self showSystemAlert:@"已复制URL到黏贴板中！"];

        } else {
            NSLog(@"无法获取到当前 URL！");
            [self showSystemAlert:@"无法获取到当前 URL！"];

        }
    }];
    
//    UIAlertAction *shareAlertAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////        [MBProgressHUD showError:@"待开发。。。"];
//        NSLog(@"无法获取到当前 URL！");
//    }];
    
    UIAlertAction *refreshAlertAction = [UIAlertAction actionWithTitle:@"刷新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wkWebView reload];
    }];
    
    UIAlertAction *scrollTopAlertAction = [UIAlertAction actionWithTitle:@"滚动到顶部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.wkWebView subviews]) {
            UIScrollView* scrollView = [[self.wkWebView subviews] objectAtIndex:0];
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alertVc addAction:safariAlertAction];
    [alertVc addAction:copyAlertAction];
    [alertVc addAction:refreshAlertAction];
    [alertVc addAction:scrollTopAlertAction];
    [alertVc addAction:cancelAlertAction];
    
//    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (topRootViewController.presentedViewController) {
//        topRootViewController = topRootViewController.presentedViewController;
//    }
//    [topRootViewController presentViewController:alertVc animated:YES completion:nil];
    
    [self presentViewController:alertVc animated:true completion:nil];
}

- (void)showSystemAlert:(NSString *)tip {
    UIAlertView *tipAlert = [[UIAlertView alloc] initWithTitle:tip message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [tipAlert show];
}


// MARK: - Lazy load 懒加载

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        // 设置网页配置文件
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 内置视频播放是否默认全屏播放
        configuration.allowsInlineMediaPlayback = YES;
        // 允许背景音乐自动播放
        configuration.mediaPlaybackRequiresUserAction = false;
        // 允许与网页交互，选择视图
        configuration.selectionGranularity = YES;
        // 最小字体
        configuration.preferences.minimumFontSize = 9.0;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.navgationBarHeight,  [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height - self.navgationBarHeight) configuration:configuration];
        
        // 背景透明
        _wkWebView.opaque = NO;
        // 隐藏滚动条
        _wkWebView.scrollView.showsVerticalScrollIndicator = YES;
        _wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
        // 开启手势触摸，前进，后退
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        
        // 添加进度条监控
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _wkWebView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
