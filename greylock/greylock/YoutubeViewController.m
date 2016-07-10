//
//  YoutubeViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/10/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "YoutubeViewController.h"

@interface YoutubeViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIWebView* webView;

@end

@implementation YoutubeViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = [NSString stringWithFormat: @"http://54.174.96.55:3000/youtube/%@/%@",
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"],
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    [self.webView setAllowsInlineMediaPlayback:YES];
    [self.webView loadRequest:urlRequest];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    
    [self.view addSubview:self.webView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
