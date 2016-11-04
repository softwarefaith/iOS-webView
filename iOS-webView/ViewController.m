//
//  ViewController.m
//  iOS-webView
//
//  Created by 蔡杰Alan on 16/11/3.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self simpleTestWKWebView];
}


- (void) simpleTestWKWebView{
    
    //1.创建webView
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    //2.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    //3.加载请求
    [webView loadRequest:request];
    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;

    //4. 视图添加
    [self.view addSubview:webView];
    
    WKWebsiteDataStore * data
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"----decidePolicyForNavigationAction");
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    NSLog(@"----didStartProvisionalNavigation");
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"----navigationResponse");
    decisionHandler(WKNavigationResponsePolicyAllow);

    
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    NSLog(@"---didCommitNavigation");

}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"---didFinishNavigation");
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"---didFailNavigation");
}


-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
    NSLog(@"d---idReceiveServerRedirectForProvisionalNavigation");

}


#pragma mark --WKUIDelegate



@end
