//
//  AppDelegate.m
//  greylock
//
//  Created by Krishna Bharathala on 7/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AWSCore/AWSCore.h>

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) ViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.viewController = [[ViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.viewController.navController = self.navController;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    AWSCognitoCredentialsProvider *credentialsProvider =
        [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                   identityPoolId:@"us-east-1:39c459c4-3f19-4cc5-8c80-41ad41d82fa3"];
    
    AWSServiceConfiguration *configuration =
        [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                    credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    return YES;

}

@end
