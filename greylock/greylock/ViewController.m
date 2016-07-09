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


- (id) init {
    self = [super init];
    if (self) {
        self.title = @"Konnected";
    }
    return self;
}

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
    
    UIBarButtonItem *joinButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(joinButtonPressed)];
    self.navigationItem.rightBarButtonItem = joinButton;
    [self requestPhoneID];
    
}

/*
 * Called on App Startup
 * Sets the phone_id in user_defaults
 */
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
                NSString *phone_id = [json objectForKey:@"phone_id"];
                [[NSUserDefaults standardUserDefaults] setObject:phone_id forKey:@"phoneID"];
                
            }] resume];
}

/*
 * Called when top right join button is pressed
 * Asks for room number and calls joinRoom;
 */
- (void) joinButtonPressed {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"What room do you want to join"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Room Number";
     }];
    
    UIAlertAction *actionOk =
    [UIAlertAction actionWithTitle:@"Done"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
     {
         [self joinRoom:alertController.textFields.firstObject.text];
     }];
    
    UIAlertAction *actionCancel =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [alertController addAction:actionCancel];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 * Called by joinButtonPressed after room is entered
 * Checks if sessionID exists and then opens intermediate VC.
 */
- (void) joinRoom:(NSString *)sessionID {
    NSString *post = [NSString stringWithFormat:@"phone_id=%@&session_id=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"],
                      sessionID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString: @"http://54.174.96.55:3000/device/register_session"]];
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
                        int count = [[dict objectForKey:@"count"] intValue];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"sessionID"];
                        IntermediateViewController *intermediateVC =
                        [[IntermediateViewController alloc] initWithCount:count];
                        [self presentViewController:intermediateVC animated:YES completion:nil];
                        
                        
                    } else {
                        NSLog(@"ERROR");
                    }
                }] resume];
}

/*
 * Call when launching widget1, will be refactored into onCollectionViewClick
 */
- (void)launchWidget1 {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"How many phones do you want to use?"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Number of phones";
     }];
    
    UIAlertAction *actionOk =
    [UIAlertAction actionWithTitle:@"Done"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
     {
         [self setWithCount:alertController.textFields.firstObject.text.intValue];
         
     }];
    
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 * Called by launch widget to go to intermediateViewController.
 */
- (void) setWithCount:(int)count {
    NSString *post = [NSString stringWithFormat:@"phone_id=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString: @"http://54.174.96.55:3000/device/create_session"];
    
    [request setURL: url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
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
                NSString *session_id = [json objectForKey:@"session_id"];
                [[NSUserDefaults standardUserDefaults] setObject:session_id forKey:@"sessionID"];
                
                IntermediateViewController *intermediateVC =
                [[IntermediateViewController alloc] initWithCount:count];
                [self presentViewController:intermediateVC animated:YES completion:nil];
                
            }] resume];
}




@end
