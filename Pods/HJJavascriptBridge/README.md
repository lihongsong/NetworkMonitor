# 关于HJJavascriptBridge

## 一.HJBridge
HJBridges是基于第三方开源库WebViewJavascriptBridge的基础上进行二次封装。主要为简化注册，调用，以及数据的清晰化。另外还添加了批量注册，通过协议方法回调。

* 初始化   

```
HJWebViewController* webVC = [HJWebViewController webView];
[[HJJSBridgeManager shareManager] setupBridge:_webVC.wkWebView navigationDelegate:_webVC];
```
* 注册事件
  * **🌰(无参数)** 

  ```
[[HJJSBridgeManager shareManager]registerHandler:@"openAlert" voidHandler:^{
}];
  ```
 * **🌰(只接受信息<字典>)** 
 
  ```
[[HJJSBridgeManager shareManager] registerHandler:@"openAlert" dictHandler:^(NSDictionary * _Nonnull data) {
}]; 
  ```
 * **🌰(即接受信息< 字典 >，又需要返回信息)** 
 
  ```
[[HJJSBridgeManager shareManager] registerHandler:@"openAlert" dictRespHandler:^(NSDictionary * _Nonnull data, HJResponseCallback  _Nullable responseCallback) {
}];
  ```
 * **🌰(WebViewJavascriptBridge原始方法)** 
 
  ```
[[HJJSBridgeManager shareManager] registerHandler:@"openAlert" handler:^(id  _Nonnull data, HJResponseCallback  _Nullable responseCallback) {
 responseCallback(@"Response data from oc");
}];
  ```
  * **🌰(批量注册事件)** 
 
  ```
[[HJJSBridgeManager shareManager] addHandlers:@[[[HJShareHander alloc]init]]];

 // HJShareHander 相关实现
 - (NSString *)handlerName {
    return @"openAlert";
 }

 - (void)didReceiveMessage:(id)message hander: (HJResponseCallback)hander {
    UIAlertView *alert = [[UIAlertView  alloc]initWithTitle:message[@"title"] message:message[@"message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
  ```
* 调用事件 
  * **🌰(无参数)** 
 
  ```
[[HJJSBridgeManager shareManager] callHandler:@"getUserInfo"];
  ```
  * **🌰(只传递信息)** 
 
  ```
[[HJJSBridgeManager shareManager] callHandler:@"getUserInfo" data:@{ @"name":@"张三",@"sex":@"男"}];
  ```
  * **🌰(即传递信息，又需回调)** 
 
  ```
[[HJJSBridgeManager shareManager] callHandler:@"getUserInfo" data:@{ @"name":@"张三",@"sex":@"男"} responseCallback:^(id responseData) {
}];
  ```

## 二.HJWebView
HJWebView是在基于WKWebView的基础上，进行二次封装。主要进行了进度条、导航条、无网视图等扩展。当然这些你都可以自定义实现。

* 🌰 **(正常情况，默认配置)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
[self.navigationController pushViewController: webVC animated:YES];
```
* 🌰 **(重新实现WKWebView的代理方法< navigationDelegate >)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
webVC.delegate = self;
[self.navigationController pushViewController: webVC animated:YES];
```
* 🌰 **(无NavigationController)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
[self presentViewController:webVC animated:YES completion:nil];
```
* 🌰 **(自定义NavigationController)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
webVC.tintColor = [UIColor magentaColor];
webVC.barTintColor = [UIColor orangeColor];
webVC.backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_close"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
webVC.closeButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_left_default"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
[self.navigationController pushViewController: webVC animated:YES];
```
* 🌰 **(自定义无网络视图)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
//自定义加载失败页面
HJRefreshView * refreshView = [[HJRefreshView alloc]initWithFrame:CGRectMake(0, 0, webVC.view.frame.size.width, webVC.view.frame.size.height)];
refreshView.block = ^{
[webVC loadURL:webVC.failUrl];
};
webVC.refreshView = refreshView;
[self.navigationController pushViewController:webVC animated:YES];
```
* 🌰 **(自定义进度条)**  

```
HJWebViewController* webVC = [HJWebViewController webView];
[webVC loadURLString:@"https://www.baidu.com"];
//自定义进度视图
UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
[progressView setTintColor:[UIColor redColor]];
[progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
[progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height - progressView.frame.size.height, self.view.frame.size.width, progressView.frame.size.height)];
[progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
webVC.progressView = progressView;
[self.navigationController pushViewController:webVC animated:YES];
```