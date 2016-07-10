//
//  ViewController.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "ViewController.h"
#import "IntermediateViewController.h"
#import <AWSS3/AWSS3.h>
#import "SVProgressHUD/SVProgressHUD.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UICollectionView *_collectionView;
}

typedef NS_ENUM(NSUInteger, MasterWidgetList) {
    MasterWidgetYoutube,
    MasterWidgetImgur,
    MasterWidgetCamera,
    MasterWidgetSharing,
    MasterWidgetFlappy,
    MasterWidgetCount,
};

@property(nonatomic) NSMutableArray *imageList;
@property(nonatomic) UIImage *chosenImage;

@end

@implementation ViewController


- (id) init {
    self = [super init];
    if (self) {
        self.title = @"Seamless";
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor =
        [UIColor colorWithRed:210.0/255 green:233.0/255 blue:248.0/255 alpha:1.0];
    // self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor =
        [UIColor colorWithRed:0 green:51.0/255 blue:102.0/255 alpha:1.0];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName :
        [UIColor colorWithRed:0 green:51.0/255 blue:102.0/255 alpha:1.0]}];
    
    UIBarButtonItem *joinButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(joinButtonPressed)];
    self.navigationItem.rightBarButtonItem = joinButton;
    [self requestPhoneID];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setSectionInset:UIEdgeInsetsMake(5, 5, 0, 5)];
    _collectionView =
        [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[UICollectionViewCell class]
        forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:68.0/255 alpha:1.0]];
    // [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_collectionView];
    
    UIImage *youtubeImage = [UIImage imageNamed:@"youtube.png"];
    UIImage *imgurImage = [UIImage imageNamed:@"imgur-white.png"];
    UIImage *cameraImage = [UIImage imageNamed:@"camera.png"];
    UIImage *sharingImage = [UIImage imageNamed:@"sharing.png"];
    UIImage *flappyImage = [UIImage imageNamed:@"flappy.png"];
    self.imageList =
        [[NSMutableArray alloc] initWithObjects:youtubeImage, imgurImage, cameraImage,
                                                sharingImage, flappyImage, nil];
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
         textField.keyboardType = UIKeyboardTypeNumberPad;
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
                        
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&error];
                        
                        NSString *widget = [json objectForKey:@"widget"];
                        [[NSUserDefaults standardUserDefaults] setObject:widget forKey:@"widgetType"];
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
- (void)launchWidget {
    [SVProgressHUD dismiss];
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"How many phones do you want to use?"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Number of phones";
         textField.keyboardType = UIKeyboardTypeNumberPad;
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
    NSString *post = [NSString stringWithFormat:@"phone_id=%@&count=%d&widget=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneID"], count,
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"widgetType"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString: @"http://54.174.96.55:3000/device/create_session"];
    
    [request setURL: url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
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
    
    if (indexPath.item == MasterWidgetYoutube) {
//        cell.backgroundColor = [UIColor colorWithRed:1.0 green:200/255.0 blue:28/255.0 alpha:1.0];
        cell.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.item == MasterWidgetImgur) {
        cell.backgroundColor = [UIColor colorWithRed:0.0 green:118/255.0 blue:192/255.0 alpha:1.0];
        backgroundImage.frame = CGRectMake(10, 10, cell.contentView.frame.size.width - 20, cell.contentView.frame.size.height-20);
    } else if (indexPath.item == MasterWidgetCamera) {
        cell.backgroundColor = [UIColor colorWithRed:236/255.0 green:64.0/255 blue:122/255.0 alpha:1.0];
        backgroundImage.frame = CGRectMake(10, 10, cell.contentView.frame.size.width - 20, cell.contentView.frame.size.height-20);
    } else if (indexPath.item == MasterWidgetSharing) {
        cell.backgroundColor = [UIColor colorWithRed:104.0/255 green:159.0/255 blue:55/255.0 alpha:1.0];
    }
    
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == MasterWidgetYoutube) {
        [self launchWidget];
        [[NSUserDefaults standardUserDefaults] setObject:@"youtube" forKey:@"widgetType"];
    } else if (indexPath.item == MasterWidgetFlappy) {
        [[NSUserDefaults standardUserDefaults] setObject:@"bird" forKey:@"widgetType"];
        [self launchWidget];
    } else if (indexPath.item == MasterWidgetSharing) {
        [[NSUserDefaults standardUserDefaults] setObject:@"photoSharing" forKey:@"widgetType"];
        [self launchSharing];
    } else if (indexPath.item == MasterWidgetCamera) {
        [[NSUserDefaults standardUserDefaults] setObject:@"cameraSharing" forKey:@"widgetType"];
        [self launchCameraSharing];
    }
}

- (void) launchSharing {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)launchCameraSharing {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.chosenImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    [self uploadImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) uploadImage {
    //Create temporary directory
    
    [SVProgressHUD showWithStatus:@"Waiting for Amazon"];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"reading 'upload' directory failed: [%@]", error);
    }
    
    //write the image to the created directory
    UIImage *image =  self.chosenImage; //Check below how do I get it
    
    NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpg"];
    
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
    
    NSData * imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];
    
    //Create upload request
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.bucket = @"greylock-hackfest";
    uploadRequest.key = @"image.jpg";
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    __weak ViewController *weakSelf = self;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
       withBlock:^id(AWSTask *task) {
           if (task.error) {
               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                   switch (task.error.code) {
                       case AWSS3TransferManagerErrorCancelled:
                       case AWSS3TransferManagerErrorPaused:
                           break;
                           
                       default:
                           NSLog(@"Error: %@", task.error);
                           break;
                   }
               } else {
                   // Unknown error.
                   NSLog(@"Error: %@", task.error);
               }
           }
           
           if (task.result) {
               [weakSelf performSelectorOnMainThread:@selector(launchWidget)
                                          withObject:nil
                                       waitUntilDone:NO];
           }
           return nil;
       }];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    float cellSize = self.view.frame.size.width/3 - 7;
    
    CGSize onebyone = CGSizeMake(cellSize, cellSize);
    CGSize twobyone = CGSizeMake(cellSize*2, cellSize);
    
    if (indexPath.item % 4 == 0 || indexPath.item % 4 == 3) {
        return twobyone;
    } else {
        return onebyone;
    }
}

@end
