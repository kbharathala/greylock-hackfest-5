//
//  WebPlayerViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "WebPlayerViewController.h"
#import "SVProgressHUD/SVProgressHUD.h"

@interface WebPlayerViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIWebView* webView;

@end

@implementation WebPlayerViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = [NSString stringWithFormat: @"http://54.174.96.55:3000/page/%@/%@",
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"],
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    [self.webView loadRequest:urlRequest];
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapWithGestureRecognizer:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.webView addGestureRecognizer:doubleTap];

    [self.view addSubview:self.webView];
}

-(BOOL)handleDoubleTapWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView: _webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    if (![urlToSave isEqualToString:@""]) {
        NSURL *imageURL = [NSURL URLWithString:urlToSave];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        
        //Save Image to Directory
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [SVProgressHUD showSuccessWithStatus:@"Image Saved"];
    }
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
