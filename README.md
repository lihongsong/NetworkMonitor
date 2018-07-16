## 网络监控

---

网络监控一般通过 NSURLProtocol 和代码注入（Hook）这两种方式来实现，由于 NSURLProtocol 作为上层接口，使用起来更为方便，因此很自然选择它作为网络监控的方案，但是 NSURLProtocol 属于 URL Loading System 体系中，应用层的协议支持有限，只支持 FTP，HTTP，HTTPS 等几个应用层协议，对于使用其他协议的流量则束手无策，所以存在一定的局限性。监控底层网络库 CFNetwork 则没有这个限制。

下面是网络采集的关键信息：

请求

* 请求url
* 请求时间 (HTTP 与 HTTPS 的 DNS 解析、TCP 握手、SSL 握手(HTTPS))
* 请求是数据大小
* 请求参数、请求body
* Cookie
* 请求头部信息

响应

* 响应数据大小
* 响应时间
* 响应数据MIME类型
* 响应编码
* 响应码
* Set-Cookie
* 响应数据类型
* 响应数据



## NSURLProtocol

---

### 使用 NSURLProtocol 监控的具体方案

创建一个继承 `NSURLProtocol` 的对象，并且注册协议。

```
	[NSURLProtocol registerClass:[NetworkMonitor class]];
```
实现 `NSURLProtocol` 的协议方法。

```
	/**
	 是否进入自定义的 NSURLProtocol
 
	 @param request 请求
	 @return 是否进入
	 */
	+ (BOOL)canInitWithRequest:(NSURLRequest *)request

	/**
	 重新设置 NSURLProtocol 信息
 
	 @param request 请求
	 @return 重新设置过后的请求
	 */
	+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request

	/**
	 被拦截的请求开始的地方
	 */
	- (void)startLoading

	/**
	 结束加载 URL 请求
	 */
	- (void)stopLoading
	
```



### 使用 NSURLProtocol 时要注意的一些问题

#### 1、拦截到的 POST 请求的 HTTPBody 为空

解决方案：不要使用HTTPBody，而使用HTTPBodyStream。

#### 2、+registerClass:方法只适用于 sharedSession

解决方案：hook NSURLSessionConfiguration 的 protocolClasses 方法，返回为自定义的 NSURLProtocol。

#### 3、可能会被别的监控三方库替换导致监控得到的是处理过后的数据

解决方案：尽量把协议的注册顺序调后。

#### 4、对 WKWebView 的请求无法监控

解决方案：通过反射的方式拿到了私有的 `class/selector`。通过 `KVC` 取到`browsingContextController`。通过把注册把 `http` 和 `https` 请求交给 `NSURLProtocol` 处理。因为使用了是私有的类和方法，所以使用时候需要对字符串做下处理，用加密的方式或者其他就可以了。

#### 5、对使用 CFNetwork 的请求无法监测

解决方案：另外通过 `hook` 的方式检测，单独使用 `NSURLProtocol` 无法解决。

#### 6、如果注册多个 NSURLProtocol 可能会导致请求发送变慢

解决方案：尽量少注册 `NSURLProtocol` 避免请求转了几次才发送出去。

## Network Hook

---

在 iOS 中 AOP 的实现是基于 Objective-C 的 Runtime 机制，实现 Hook 的三种方式分别为：Method Swizzling、NSProxy 和 Fishhook。前两者适用于 Objective-C 实现的库，如 NSURLConnection 和 NSURLSession ，Fishhook 则适用于 C 语言实现的库，如 CFNetwork。

下面是阿里百川码力监控给出的三个类网络接口需要 hook 的方法

### NSURLConnection

```
	+ sendSynchronousRequest: returningResponse: error:
	+ sendAsynchronousRequest: queue: completionHandler:
	
	- initWithRequest: delegate: startImmediately:
    - initWithRequest: delegate:

    - start
    - cancel
```

### NSURLSession

```
	- delegate
	
	+ sessionWithConfiguration:
	+ sessionWithConflguration:delegate:delegateQueue:
	
	- dataTaskWithURL:
	- dataTaskWithURL:completionHandler:
	- dataTaskWithRequest:
	- dataTaskWithRequest:completionHandler:

	- downloadTaskWithURl:	
	- downloadTaskWithURl:completionHandler:
	- downloadTaskWithResumeData:
	- downloadTaskWithResumeData:completionHandler:
	- downloadTaskWithRequest:
	- downloadTaskWithRequest:completionHandler:

	- uploadTaskWithRequest:fromFile:
	- uploadTaskWithRequest:fromData:
	- uploadTaskWithRequest:fromFile:completionHandler:
	- uploadTaskWithRequest:fromData:completionHandler:
	- uploadTaskWithRequest:fromRequest:
```
### NSURLSessionTask

```
	- resume
```

### CFNetwork
对 `C` 函数的 mock 需要用到 Dynamic Loader Hook 库函数 - [fishhook](https://github.com/facebook/fishhook)

```
	CFReadStreamCreateForHTTPRequest(..)
	CFReadStreamCreateForStreamedHTTPRequest(..)
	CFReadStreamCreateSetClient(..)
	CFReadStreamCreateOpen(..)
	CFReadStreamCreateRead(..)
```

### NSInputStream

```
	- setDelegate:
	- delegate
	- open
	- read:maxLength:
```



#### 参考文章：
* [美团移动端性能监控方案Hertz](https://tech.meituan.com/hertz.html)
* [美团外卖移动端性能监测体系实现](https://mp.weixin.qq.com/s/MwgjpHj_5RaG74Z0JjNv5g)
* [使用NSURLProtocol时要注意的一些问题](http://liujinlongxa.com/2016/12/20/使用NSURLProtocol注意的一些问题/)
* [NetworkEye](https://github.com/zixun/NetworkEye)
* [iOS 开发中使用 NSURLProtocol 拦截 HTTP 请求](https://github.com/Draveness/analyze/blob/master/contents/OHHTTPStubs/iOS%20开发中使用%20NSURLProtocol%20拦截%20HTTP%20请求.md)
* [iOS-Monitor-Platform](https://github.com/aozhimin/iOS-Monitor-Platform/blob/master/iOS-Monitor-Platform_Network.md)
* [让 WKWebView 支持 NSURLProtocol](https://blog.yeatse.com/2016/10/26/support-nsurlprotocol-in-wkwebview/)
* [iOS 流量监控分析](http://www.cocoachina.com/ios/20180606/23691.html)
* [网易NeteaseAPM iOS SDK技术实现分享](http://www.infoq.com/cn/articles/netease-ios-sdk-neteaseapm-technology-share)