//
//  IntermediateViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "IntermediateViewController.h"
#import "WebPlayerViewController.h"

@interface IntermediateViewController ()

@property(nonatomic, strong) UIImageView *configurationView;

@end

@implementation IntermediateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImage *configImage = [UIImage imageNamed:@"2-horizontal.png"];
    self.configurationView = [[UIImageView alloc] initWithImage:configImage];
    [self.configurationView setFrame:CGRectMake(0, 0, 300, 300)];
    [self.configurationView setCenter:CGPointMake(width/2, height/2)];
    [self.view addSubview:self.configurationView];
    [self.configurationView setHidden:YES];
    
    UIButton *readyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [readyButton setTitle:@"Ready!!" forState:UIControlStateNormal];
    [readyButton sizeToFit];
    [readyButton setCenter:CGPointMake(width/2, height - 100)];
    [readyButton addTarget:self
                      action:@selector(readyPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readyButton];
    
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"How many phones do you want to use?"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Room Code";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Number of phones";
     }];
    
    UIAlertAction *actionOk =
        [UIAlertAction actionWithTitle:@"Done"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
         {
//             int count = [[alertController.textFields firstObject].text intValue];
//             if (count == 2) {
//                 [self.configurationView setHidden:NO];
//             }
             [self alertInformationEntered];
             
         }];
    
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) readyPressed {
    WebPlayerViewController *webplayer = [[WebPlayerViewController alloc] init];
    [self.navigationController pushViewController:webplayer animated:YES];
    
}

- (void) alertInformationEntered {
    NSString *url = [NSString stringWithFormat:@"http://54.174.96.55:3000/device/create_session/%@",
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSHTTPURLResponse *responseCode;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&responseCode
                                                             error:&error];
    
    if ([responseCode statusCode] != 200) {
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
}


@end
