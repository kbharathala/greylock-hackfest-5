//
//  WebPlayerViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "WebPlayerViewController.h"

@interface WebPlayerViewController () <UIGestureRecognizerDelegate>

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
    
    UITapGestureRecognizer *doubleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.webView addGestureRecognizer:doubleTap];
    
    [self.view addSubview:self.webView];
}

- (void) handleDoubleTap {
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"leavingWebView"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
