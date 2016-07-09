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
    self.view.backgroundColor = [UIColor redColor];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImage *configImage;
    if (_count == 2) {
        configImage = [UIImage imageNamed:@"2-horizontal.png"];
    } else {
        configImage = [UIImage imageNamed:@"1-vertical.png"];
    }
    
    self.configurationView = [[UIImageView alloc] initWithImage:configImage];
    [self.configurationView setFrame:CGRectMake(0, 0, 300, 300)];
    [self.configurationView setCenter:CGPointMake(width/2, height/2)];
    [self.view addSubview:self.configurationView];
    
    UILabel *sessionLabel = [[UILabel alloc] init];
    [sessionLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]];
    [sessionLabel sizeToFit];
    [sessionLabel setCenter:CGPointMake(width/2, 100)];
    [self.view addSubview:sessionLabel];
    
    UIButton *readyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [readyButton setTitle:@"Ready!!" forState:UIControlStateNormal];
    [readyButton sizeToFit];
    [readyButton setCenter:CGPointMake(width/2, height - 100)];
    [readyButton addTarget:self
                      action:@selector(readyPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readyButton];
}

- (void) readyPressed {
    WebPlayerViewController *webplayer = [[WebPlayerViewController alloc] init];
    [self.navigationController pushViewController:webplayer animated:YES];
    
}


@end
