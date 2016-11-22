//
//  HQYSharedManager.h
//  DemoMockSingleton
//
//  Created by apple on 16/11/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQYSharedManager : NSObject

+ (instancetype)sharedManager;
- (NSString *)loadCurrentUserName;

@end
