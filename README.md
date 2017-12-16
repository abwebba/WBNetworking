# WBNetworking
网络框架

基于AFNetworking封装的网络框架

特点：

1、可快速更换其他网络框架。

2、每个接口的业务逻辑都可以方便的做个性化处理。

3、Controller（调用者）销毁了，接口会自动取消请求，节省网络资源。

4、可通过闭包、代理回调请求的数据。

5、轻便、使用简单。



一、集成方法

1、把WBNetworking加到你的项目里。

2、引入AFNetworking。



二、使用方法

1、创建文件继承 WBAPIManager。

2、实现遵循<WBAPIManager>协议。
  
3、实现方法 

- (NSString *)methodName;

- (WBAPIManagerRequestType)requestType;

4、startRequest 开始请求。
