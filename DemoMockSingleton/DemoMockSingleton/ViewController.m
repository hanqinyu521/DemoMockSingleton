//
//  ViewController.m
//  DemoMockSingleton
//
//  Created by apple on 16/11/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ViewController.h"
#import "HQYSharedManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)settingUserName{
    _currentUserName = [self loadUserName];
}

- (NSString *)loadUserName{
    NSString *user = [[HQYSharedManager sharedManager] loadCurrentUserName];
    NSLog(@"%@",user);
    return user;
}

@end
