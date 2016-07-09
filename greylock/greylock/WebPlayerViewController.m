//
//  WebPlayerViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "WebPlayerViewController.h"

@interface WebPlayerViewController ()

@property(nonatomic, strong) UIWebView* webView;

@end

@implementation WebPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = @"http://54.174.96.55:3000/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    [self.webView loadRequest:urlRequest];
    
    [self.view addSubview:self.webView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
