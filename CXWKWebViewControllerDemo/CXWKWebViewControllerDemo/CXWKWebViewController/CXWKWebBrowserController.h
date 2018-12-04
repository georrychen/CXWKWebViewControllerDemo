//
//  CXWKWebBrowserController.h
//  CXWKWebViewControllerDemo
//
//  Created by Xu Chen on 2018/12/4.
//  Copyright © 2018 xu.yzl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXWKWebBrowserController : UIViewController
+ (instancetype)cx_loadWkWebViewWithUrlString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
