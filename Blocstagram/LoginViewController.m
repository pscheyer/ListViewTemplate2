//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Peter Scheyer on 3/1/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) UIButton *homeButton;

@end


@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI {
    return @"http://www.ajartech.com";
}

- (void) loadView {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    self.title = @"Login";
    
    
    self.homeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.homeButton setEnabled:YES];
    [self.homeButton setTitle:NSLocalizedString(@"Login Screen", @"Login Screen") forState:UIControlStateNormal];
    [self.homeButton addTarget:self.webView action:@selector(reloadLoginPage) forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:self.homeButton];
    
    self.webView = webView;
    self.view = webView;
}

-(void) reloadLoginPage {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) ;
    
    self.webView.frame = CGRectMake(0,0, width, browserHeight);
//    self.homeButton.frame = CGRectMake(0, CGRectGetMaxY(self.webView.frame), width, itemHeight);


}

- (void) viewDidLoad
{
    [super viewDidLoad];
    //addl setup
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    
    [self setTitle:@"Login"];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(reloadLoginPage)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
}

- (void) dealloc {
    //removing the line causes a weird flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
    [self clearInstagramCookies];
    
    //    see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1//
    self.webView.delegate = nil;
}

/**
 clears instagram cookies. Don't want to cache the credentials with the cookies. */
- (void) clearInstagramCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        // this contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    return YES;
}




@end