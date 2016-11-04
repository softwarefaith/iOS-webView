#优雅理解WKWebView

##一.背景介绍

UIWebView自iOS2就有，iOS8出现了WKWebView，毫无疑问WKWebView将逐步取代笨重的UIWebView。通过一些测试来看发现UIWebView占用过多内存，且内存峰值更是夸张。然而，新一代的WKWebView网页加载速度也有进一步的提升。

下面我简单的罗列一些优势：

- 更多的支持HTML5的特性
- 官方宣称的高达60fps的滚动刷新率以及内置手势
- Safari相同的JavaScript引擎
- 将UIWebViewDelegate与UIWebView拆分成了14类与3个协议
- 另外用的比较多的，增加加载进度属性：estimatedProgress

####[官方文档说明](https://developer.apple.com/reference/webkit)

##二.UIWebView简单说明
 UIWebView使用不做详细介绍，他的功能不仅可以加载HTML页面，还支持pdf、word、txt、各种图片等等的显示。其中代理协议使用***UIWebViewDelegate***，另外补充一点就是关于JS交互


- js执行OC代码：

js是不能执行oc代码的，但是可以变相的执行，js可以将要执行的操作封装到网络请求里面，然后oc拦截这个请求，获取url里面的字符串解析即可，这里用到代理协议的
<pre style="background-color:#000033">
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType函数。
</pre>

- oc调取写好的js代码

<pre style="background-color:#000033">
// 实现自动定位js代码, htmlLocationID为定位的位置(由js开发人员给出)，实现自动定位代码，应该在网页加载完成之后再调用
NSString *javascriptStr = [NSString stringWithFormat:@"window.location.href = '#%@'",htmlLocationID];
// webview执行代码
[self.webView stringByEvaluatingJavaScriptFromString:javascriptStr];
// 获取网页的title
NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]
</pre>

##三.WKWebView使用


####基本使用
先导入：#import <WebKit/WebKit.h>

以下代码展示了WKWebView简单显示
<pre style="background-color:#000033">
    //1.创建webView
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    //2.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    //3.加载请求
    [webView loadRequest:request];
    //4. 视图添加
    [self.view addSubview:webView];
</pre>

####实用函数

<pre style="background-color:#000033">
- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(macosx(10.11), ios(9.0));

- (WKNavigation *)loadRequest:(NSURLRequest *)request;
- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
</pre>

####网页导航刷新相关函数
和UIWebview几乎一样，不同的是有返回值，WKNavigation(已更新)，另外增加了函数reloadFromOrigin和goToBackForwardListItem。

- reloadFromOrigin会比较网络数据是否有变化，没有变化则使用缓存，否则从新请求。
- goToBackForwardListItem：比向前向后更强大，可以跳转到某个指定历史页面

<pre>
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
- (WKNavigation *)goBack;
- (WKNavigation *)goForward;
- (WKNavigation *)reload;
- (WKNavigation *)reloadFromOrigin; // 增加的函数
- (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item; // 增加的函数
- (void)stopLoading;
</pre>

####相关类介绍


<pre style="background-color:#000033"> 
WKBackForwardList: 之前访问过的 web 页面的列表，可以通过后退和前进动作来访问到。
WKBackForwardListItem: webview 中后退列表里的某一个网页。
WKFrameInfo: 包含一个网页的布局信息。
WKNavigation: 包含一个网页的加载进度信息。
WKNavigationAction: 包含可能让网页导航变化的信息，用于判断是否做出导航变化。
WKNavigationResponse: 包含可能让网页导航变化的返回内容信息，用于判断是否做出导航变化。
WKPreferences: 概括一个 webview 的偏好设置。
WKProcessPool: 表示一个 web 内容加载池。
WKUserContentController: 提供使用 JavaScript post 信息和注射 script 的方法。
WKScriptMessage: 包含网页发出的信息。
WKUserScript: 表示可以被网页接受的用户脚本。
WKWebViewConfiguration: 初始化 webview 的设置。
WKWindowFeatures: 指定加载新网页时的窗口属性。

WKWebsiteDataStore:website站点使用各种数据类型，比如：cookies, disk and memory caches, and persistent data such as WebSQL,IndexedDB databases, and local storage
 
 WKWebViewConfiguration:webview初始化配置
</pre>

####代理协议

- WKNavigationDelegate

该代理提供的方法，可以用来追踪加载过程（页面开始加载、加载完成、加载失败）、决定是否执行跳转。

<pre style="background-color:#000033">
// 2.页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
//3. 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
// 4.页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
</pre>

页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）

<pre style="background-color:#000033">
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
// 3.在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
// 1.在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
</pre>

***<strong>数字表示了正确加载时的调用顺序</strong>***

- WKUIDelegate

UI界面相关，原生控件支持，三种提示框：输入、确认、警告。首先将web提示框拦截然后再做处理。

<pre style="background-color:#000033">
/// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
/// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler;
/// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;
/// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
</pre>

- WKScriptMessageHandler
这个协议中包含一个必须实现的方法，这个方法是提高App与web端交互的关键，它可以直接将接收到的JS脚本转为OC或Swift对象。


<pre style="background-color:#000033">
/// message: 收到的脚本信息.
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
</pre>

####注意事项

- 1.线程不安全
来源于苹果文档
<pre>
Concurrency Note
The WebKit framework is not thread-safe. If you call functions or methods in this framework, you must do so exclusively on the main program thread.
</pre>


####WKWebView应用

####1. 修改docunment

<pre style="background-color:#000033">
WKUserContentController *wkuserCVC = [[WKUserContentController alloc]init];
    WKUserScript *script = [[WKUserScript alloc]initWithSource:@"js code" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [wkuserCVC addUserScript:script];
</pre>

####2.监听web内容加载进度、是否加载完成
WKWebView 有一个属性estimatedProgress,这个就是加载进度。我们利用KVO监听这个属性值的变化，就可以显示加载进度了。
<pre>
[self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
</pre>

####3. 跨域问题
跨域问题可以采用手动跳转的方式
在
<pre>
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
   //这里拦截判断
}

</pre>

###补充：HTML5 性能数据了解

- 白屏时间

白屏时间无论安卓还是iOS在加载网页的时候都会存在的问题，也是目前无法解决的；

- 页面耗时

页面耗时指的是开始加载这个网页到整个页面load完成即渲染完成的时间；

- 加载链接的一些性能数据

重定向时间，DNS解析时间，TCP链接时间，request请求时间，response响应时间，dom节点解析时间，page渲染时间，同时我们还需要抓取资源时序数据，


***什么是资源时序数据呢？***

每个网页是有很多个资源组成的，有.js、.png、.css、.script等等，我们就需要将这些每个资源链接的耗时拿到，是什么类型的资源，完整链接；对于客户来说有了这些还不够，还需要JS错误，页面的ajax请求。JS错误获取的当然是堆栈信息和错误类型。ajax请求一般是获取三个时间，响应时间，ajax下载时间，ajax回调时间。
