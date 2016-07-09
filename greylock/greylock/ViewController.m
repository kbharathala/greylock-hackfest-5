//
//  ViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "ViewController.h"
#import "WebPlayerViewController.h"
#import "IntermediateViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIButton *genericWidget = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [genericWidget setTitle:@"Widget 1" forState:UIControlStateNormal];
    [genericWidget sizeToFit];
    [genericWidget setCenter:CGPointMake(width/2, height/2)];
    [genericWidget addTarget:self
                      action:@selector(launchWidget1)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:genericWidget];
    
    [self requestPhoneID];
    
}

- (void) requestPhoneID {
    NSString *url = [NSString stringWithFormat:@"http://54.174.96.55:3000/device/initialize"];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                if (urlResponse.statusCode != 200) {
                    NSLog(@"Error getting %@, HTTP status code %li", url, (long)urlResponse.statusCode);
                    return;
                }
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
                
                NSLog(@"%@", json);
                
            }] resume];
}

- (void)launchWidget1 {
    IntermediateViewController *intermediateVC = [[IntermediateViewController alloc] init];
    [self.navigationController pushViewController:intermediateVC animated:YES];
}




@end
