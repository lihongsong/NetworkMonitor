### 接入方式：

```swift 
    source 'git@172.16.0.245:Finance_SDK/iOS_Loan_Spec.git'

    pod 'HJNetwork'
```

### 简介:

网络请求的SDK,可单独配置服务器域名,回调的处理,头部信息的插入。

### 使用方法：

需要先通过创建 NSObject 的分类进行 `HJNetworkProtocol` 的配置

``` swift 
/**
 API 服务器域名
 */
+ (NSString *)hj_APIServer;

/**
 参数签名
 */
+ (NSDictionary *_Nullable)hj_signParameters:(NSDictionary *_Nullable)paramters;

/**
 创建网络连接默认的参数构造函，每次网络连接都将回调该函数
 此方法可选实现
 */
+ (void)hj_setupRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer;
+ (void)hj_setupResponseSerializer:(AFHTTPResponseSerializer *)responseSerializer;

/**
 处理server返回的response，非Model化处理
 */
+ (void)hj_receiveResponseObject:(id _Nullable)responseObject
                            task:(NSURLSessionDataTask *_Nullable)task
                           error:(NSError *_Nullable)error
                         success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 处理server返回的response，Model化处理
 */
+ (id _Nullable)hj_parseResponseObject:(id _Nullable)responseObject;
```

接下来创建请求:
可以是一个 NSObject 的分类,在分类中调用`hj_requestXXX`的相关方法发送请求:

``` swift 
    [self hj_requestModelAPI:IL_POST_REPAYMENT_PLAN_PATH
                         parameters:param
                         completion:completion];
```

