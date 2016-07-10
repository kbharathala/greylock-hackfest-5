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
    
    NSString *urlString = [NSString stringWithFormat: @"http://54.174.96.55:3000/%@/%@/%@",
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetType"],
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
    
    UITapGestureRecognizer *tripleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap)];
    tripleTap.numberOfTouchesRequired = 1;
    tripleTap.numberOfTapsRequired = 3;
    tripleTap.delegate = self;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetType"] isEqualToString:@"youtube"]) {
        [self.webView addGestureRecognizer:tripleTap];
    }
    [self.view addSubview:self.webView];
}

- (void) handleTripleTap {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
