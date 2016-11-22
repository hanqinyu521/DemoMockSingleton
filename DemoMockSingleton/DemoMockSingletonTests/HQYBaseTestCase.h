//
//  HQYBaseTestCase.h
//  DemoMockSingleton
//
//  Created by apple on 16/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+SupersequentImplementation.h"
#import <OCMock.h>

#define JTKMOCK_SINGLETON(__className,__sharedMethod)               \
JTKMOCK_SINGLETON_CATEGORY_DECLARE(__className)                     \
JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT(__className,__sharedMethod)    \

#define JTKMOCK_SINGLETON_CATEGORY_DECLARE(__className)         \
\
@interface __className (UnitTest)                               \
\
+ (instancetype)JTKCreateClassMock;                             \
\
+ (instancetype)JTKCreatePartialMock:(__className *)obj;        \
\
+ (void)JTKReleaseMock;                                         \
\
@end


#define JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT(__className,__sharedMethod)    \
\
static __className *mock_singleton_##__className = nil;                     \
\
@implementation __className (UnitTest)                                      \
\
+ (instancetype)__sharedMethod {                                            \
if (mock_singleton_##__className) return mock_singleton_##__className;  \
return invokeSupersequentNoParameters();                             \
}                                                                           \
+ (instancetype)JTKCreateClassMock {                                        \
mock_singleton_##__className = OCMClassMock([__className class]);       \
return mock_singleton_##__className;                                    \
}                                                                           \
\
+ (instancetype)JTKCreatePartialMock:(__className *)obj {                   \
mock_singleton_##__className = OCMPartialMock(obj);                     \
return mock_singleton_##__className;                                    \
}                                                                           \
\
+ (void)JTKReleaseMock {                                                    \
mock_singleton_##__className = nil;                                     \
}                                                                           \
\
@end


@interface HQYBaseTestCase : XCTestCase

@end
