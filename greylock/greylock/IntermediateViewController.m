//
//  IntermediateViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "IntermediateViewController.h"
#import "WebPlayerViewController.h"
#import "SVProgressHUD/SVProgressHUD.h"

@interface IntermediateViewController ()

@property(nonatomic, strong) UIImageView *configurationView;

@property (nonatomic) int count;

@end

@implementation IntermediateViewController

- (id) initWithCount:(int)count {
    self = [super init];
    if (self) {
        _count = count;
    }
    return self;
}

//- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"leavingWebView"] boolValue]) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"leavingWebView"];
//        [self.navigationController popViewControllerAnimated:NO];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImage *configImage;
    if (_count == 2) {
        configImage = [UIImage imageNamed:@"2-1.png"];
    } else {
        configImage = [UIImage imageNamed:@"1-vertical.png"];
    }
    
    self.configurationView = [[UIImageView alloc] initWithImage:configImage];
    [self.configurationView setFrame:CGRectMake(0, 0, 100, 100)];
    [self.configurationView setCenter:CGPointMake(width/2, height/2)];
    [self.view addSubview:self.configurationView];
    
    UILabel *sessionLabel = [[UILabel alloc] init];
    NSString *string = [NSString stringWithFormat:@"Enter this room id on all the devices: %@",
                        [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]];
    [sessionLabel setText: string];
    [sessionLabel setTextColor:[UIColor blackColor]];
    [sessionLabel sizeToFit];
    [sessionLabel setCenter:CGPointMake(width/2, height-150)];
    [self.view addSubview:sessionLabel];
    
    UILabel *readyLabel = [[UILabel alloc] init];
    NSString *string2 = [NSString stringWithFormat:@"Tap your phones screen to calibrate in the order displayed on the screen."];
    [readyLabel setText: string2];
    NSLog(@"%@", string2);
    [readyLabel setTextColor:[UIColor blackColor]];
    [readyLabel sizeToFit];
    [readyLabel setCenter:CGPointMake(width/2, height-100)];
    [self.view addSubview:readyLabel];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self startCalibrateSession];
}

- (void) startCalibrateSession {
    NSString *post = [NSString stringWithFormat:@"phone_id=%@&session_id=%@&timestamp=%f&screen_height=%f&screen_width=%f",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"],
                      [[NSDate date] timeIntervalSince1970] * 1000,
                      self.view.frame.size.height, self.view.frame.size.width];
    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString: @"http://54.174.96.55:3000/device/calibrate"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (data) {
                        NSDictionary *dict =
                        [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&error];
                        NSLog(@"%@", dict);
                        if ([[dict objectForKey:@"status"] isEqualToString:@"success"]) {
                            [SVProgressHUD showWithStatus:@"Waiting for other phones"];
                            [self checkReady];
                        } else {
                            NSLog(@"ERROR1");
                        }
                    } else {
                        NSLog(@"ERROR2");
                    }
                }] resume];
}

- (void)checkReady {
    NSString *post = [NSString stringWithFormat:@"session_id=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString: @"http://54.174.96.55:3000/device/calibrate/ready"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    __weak IntermediateViewController *weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (data) {
                        NSDictionary *dict =
                        [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&error];
                        NSLog(@"%@", dict);
                        if ([[dict objectForKey:@"calibration_ready"] isEqualToString:@"true"]) {
                            [weakSelf performSelectorOnMainThread:@selector(pushDetail) withObject:nil waitUntilDone:NO];
                        } else {
                            [self wait];
                        }
                    } else {
                        NSLog(@"ERROR");
                    }
                }] resume];
}

- (void) pushDetail {
    [SVProgressHUD dismiss];
    WebPlayerViewController *webplayer = [[WebPlayerViewController alloc] init];
    [self.navigationController pushViewController:webplayer animated:YES];
}

- (void)wait {
    sleep(0.5);
    [self checkReady];
    
}


@end
