//
//  DemoMockSingletonTest.m
//  DemoMockSingleton
//
//  Created by apple on 16/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HQYBaseTestCase.h"
#import "HQYSharedManager.h"
#import "ViewController.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

JTKMOCK_SINGLETON(HQYSharedManager, sharedManager)

#pragma clang diagnostic pop


@interface DemoMockSingletonTest : HQYBaseTestCase
{
    ViewController *_vc;
    ViewController *_vcMock;
}
@end

@implementation DemoMockSingletonTest

- (void)setUp {
    [super setUp];
    
    _vc = [ViewController new];
    _vcMock = OCMPartialMock(_vc);
    
   // [HQYSharedManager JTKCreateClassMock];
    [HQYSharedManager JTKCreatePartialMock:[HQYSharedManager sharedManager]];
    OCMStub([mock_singleton_HQYSharedManager loadCurrentUserName]).andReturn(@"stub success");
    
}

- (void)tearDown {
    _vc = nil;
    _vcMock = nil;
    [HQYSharedManager JTKReleaseMock];
    [super tearDown];
}

- (void)testLoadCurrentUserName{
    NSString *userName = [[HQYSharedManager sharedManager] loadCurrentUserName];
    XCTAssertEqual(userName, @"stub success");
}

- (void)testViewControllerLoadUserName{
    [_vc settingUserName];
    XCTAssertTrue([_vc.currentUserName isEqualToString:@"stub success"],@"没有成功赋值 错误显示：%@",_vc.currentUserName);
}
@end
