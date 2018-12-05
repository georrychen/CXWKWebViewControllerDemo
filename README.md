# CXWKWebViewControllerDemo
WKWebView 浏览器视图的简单封装  

效果如下图：  

![](https://github.com/sunrisechen007/CXWKWebViewControllerDemo/blob/master/demo.gif)

使用方法：只需要传入 `url` 即可 
 
```
let vc = CXWKWebBrowserController.cx_loadWkWebView(withUrlString:"https://www.jd.com/") 
present(vc, animated: true, completion: nil) 
```
