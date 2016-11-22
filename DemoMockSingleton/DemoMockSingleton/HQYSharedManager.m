//
//  HQYSharedManager.m
//  DemoMockSingleton
//
//  Created by apple on 16/11/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "HQYSharedManager.h"

@implementation HQYSharedManager


+ (instancetype)sharedManager{
    static HQYSharedManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HQYSharedManager new];
    });
    return manager;
}

- (NSString *)loadCurrentUserName{
    return @"Matt";
}


@end
