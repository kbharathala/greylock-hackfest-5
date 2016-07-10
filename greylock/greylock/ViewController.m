//
//  ViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "ViewController.h"
#import "IntermediateViewController.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    UICollectionView *_collectionView;
}

typedef NS_ENUM(NSUInteger, MasterWidgetList) {
    MasterWidgetYoutube,
    MasterWidgetCount,
};

@property(nonatomic) NSMutableArray *imageList;

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
    
    UIBarButtonItem *joinButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(joinButtonPressed)];
    self.navigationItem.rightBarButtonItem = joinButton;
    [self requestPhoneID];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView =
        [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[UICollectionViewCell class]
        forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_collectionView];
    
    UIImage *youtubeImage = [UIImage imageNamed:@"youtube.png"];
    self.imageList = [[NSMutableArray alloc] initWithObjects:youtubeImage, nil];
    
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
    [UIAlertAction actionWithTitle:@"Join"
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
    
    __weak ViewController *weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (data) {
                        [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"sessionID"];
                        [weakSelf performSelectorOnMainThread:@selector(pushDetail) withObject:nil waitUntilDone:NO];
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
    
    UIAlertAction *actionCancel =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [alertController addAction:actionCancel];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 * Called by launch widget to go to intermediateViewController.
 */
- (void) setWithCount:(int)count {
    NSString *post = [NSString stringWithFormat:@"phone_id=%@&count=%d",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"], count];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString: @"http://54.174.96.55:3000/device/create_session"];
    
    [request setURL: url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSLog(@"ENTERING CREATE_SESSION REQUEST");
    
    __weak ViewController *weakSelf = self;
    __weak NSNumber *weakCount = [NSNumber numberWithInt:count];
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
                NSLog(@"THIS IS WHERE CREATE SESSION IS LOGGING");
                NSLog(@"%@", json);
                NSString *session_id = [NSString stringWithFormat:@"%@", [json objectForKey:@"session_id"]];
                [[NSUserDefaults standardUserDefaults] setObject:session_id forKey:@"sessionID"];
                
                [weakSelf performSelectorOnMainThread:@selector(pushDetail:) withObject:weakCount waitUntilDone:NO];
            }] resume];
}

- (void) pushDetail:(NSNumber*)count {
    IntermediateViewController *intermediateVC =
    [[IntermediateViewController alloc] initWithCount:[count intValue]];
    [self.navigationController pushViewController:intermediateVC animated:YES];
}

- (void) pushDetail {
    IntermediateViewController *intermediateVC = [[IntermediateViewController alloc] init];
    [self.navigationController pushViewController:intermediateVC animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MasterWidgetCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell=
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier"
                                                  forIndexPath:indexPath];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[self.imageList objectAtIndex:indexPath.item]];
    backgroundImage.frame = cell.contentView.bounds;
    [cell.contentView addSubview:backgroundImage];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == MasterWidgetYoutube) {
        [self launchWidget1];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width/2 - 5, self.view.frame.size.width/2 - 5);
}




@end
