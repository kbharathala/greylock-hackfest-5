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
#import "YoutubeViewController.h"

@interface IntermediateViewController ()

@property(nonatomic, strong) UIImageView *configurationView;
@property(nonatomic, strong) UIImageView *configurationView2;

@property(nonatomic, strong) UIButton *calibrateButton;
@property(nonatomic, strong) UILabel *sessionLabel;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImage *configImage;
    UIImage *configImage2;
    if (_count == 1) {
        configImage = [UIImage imageNamed:@"1-1.png"];
        configImage2 = [UIImage imageNamed:@"1-2.png"];
    } else if (_count == 2) {
        configImage = [UIImage imageNamed:@"2-1.png"];
        configImage2 = [UIImage imageNamed:@"2-2.png"];
    } else if (_count == 3) {
        configImage = [UIImage imageNamed:@"3-1.png"];
        configImage2 = [UIImage imageNamed:@"3-2.png"];
    } else if (_count == 4) {
        configImage = [UIImage imageNamed:@"4-1.png"];
        configImage2 = [UIImage imageNamed:@"4-2.png"];
    }
    
    self.configurationView = [[UIImageView alloc] initWithImage:configImage];
    [self.configurationView setFrame:CGRectMake(0, 0, 100, 100)];
    [self.configurationView setCenter:CGPointMake(120, 150)];
    [self.view addSubview:self.configurationView];
    
    self.configurationView2 = [[UIImageView alloc] initWithImage:configImage2];
    [self.configurationView2 setFrame:CGRectMake(0, 0, 100, 100)];
    [self.configurationView2 setCenter:CGPointMake(width - 120, 150)];
    [self.view addSubview:self.configurationView2];
    
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.calibrateButton setImage:[UIImage imageNamed:@"tapMeImage.png"] forState:UIControlStateNormal];
    self.calibrateButton.titleLabel.textColor = [UIColor blackColor];
    [self.calibrateButton addTarget:self action:@selector(roundButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    
    //width and height should be same value
    self.calibrateButton.frame = CGRectMake(0, 0, 200, 200);
    self.calibrateButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2 + 30);
    
    //Clip/Clear the other pieces whichever outside the rounded corner
    self.calibrateButton.clipsToBounds = YES;
    
    //half of the width
    self.calibrateButton.layer.cornerRadius = 200/2.0f;
    self.calibrateButton.layer.borderColor=[UIColor redColor].CGColor;
    self.calibrateButton.layer.borderWidth=2.0f;
    
    [self.view addSubview:self.calibrateButton];
    
    self.sessionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-100, 100)];
    NSString *string = [NSString stringWithFormat:@"Enter this room id on all the devices: %@",
                        [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]];
    [self.sessionLabel setText: string];
    [self.sessionLabel setTextColor:[UIColor blackColor]];
    [self.sessionLabel sizeToFit];
    [self.sessionLabel setCenter:CGPointMake(width/2, height-150)];
    [self.view addSubview:self.sessionLabel];
    
    UILabel *readyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width - 80, 100)];
    NSString *string2 = [NSString stringWithFormat:@"Calibrate by touching your phone in the specified order."];
    [readyLabel setNumberOfLines:0];
    [readyLabel setText: string2];
    [readyLabel setTextColor:[UIColor blackColor]];
    [readyLabel setCenter:CGPointMake(width/2, height-100)];
    [self.view addSubview:readyLabel];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            self.calibrateButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2 + 30);
            [self.sessionLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-150)];
            
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            self.calibrateButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2 + 30);
            [self.sessionLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-150)];
            break;
            
        case UIDeviceOrientationFaceUp:
            break;
            
        default:
            self.calibrateButton.center = CGPointMake(self.view.frame.size.width/2 + 150, self.view.frame.size.height/2 );
            [self.sessionLabel setCenter:CGPointMake(180, self.view.frame.size.height-70)];
            break;
    };
}

//The event handling method
- (void)roundButtonDidTap {
    [self.calibrateButton setHidden:YES];
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
                            [SVProgressHUD showErrorWithStatus:@"Status was failure"];
                            NSLog(@"ERROR1");
                        }
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"Server has crashed"];
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
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetType"] isEqualToString:@"youtube"] ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"widgetType"] isEqualToString:@"bird"]) {
        YoutubeViewController *youtubeVC = [[YoutubeViewController alloc] init];
        [self.navigationController pushViewController:youtubeVC animated:YES];
    } else {
        WebPlayerViewController *webplayer = [[WebPlayerViewController alloc] init];
        [self.navigationController pushViewController:webplayer animated:YES];
    }
}

- (void)wait {
    sleep(0.5);
    [self checkReady];
    
}


@end
