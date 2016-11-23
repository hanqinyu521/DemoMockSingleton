#iOS单元测试（一）如何Mock-Singleton 单例测试

- Mock单例


单例模式是我们在iOS中最常使用的设计模式之一。单例模式不需要传递任何参数，它通过一个类方法返回一个唯一的实例，与我们平常通过实例化生成一个个实例的场景有所不同。那么我们要stub一个单例的类的实例方法话是必须要返回一个mock对象，因为只有mock对象才可以做stub操作。那么我们应该如何mock单例类呢，下面有一段宏主要目的是通过category重写sharedManage让它返回我们的mock对象，这样只要在测试case中初始化一下mock，sharedManage不管在哪里调用就都会返回我们需要的mock对象了。
好下面我们开始一步一步分析此宏并运用到项目中。



```
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

```


好我们来看第一段
```

#define JTKMOCK_SINGLETON(__className,__sharedMethod)               \
JTKMOCK_SINGLETON_CATEGORY_DECLARE(__className)                     \
JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT(__className,__sharedMethod)    \
```

首先定义了JTKMOCK_SINGLETON宏有俩个参数, 第一个__className是类名第二个参数是方法名，这里先补充一下宏知识为什么要加双下划线，因为这样是为了避免变量名相同而导致问题的可能性，后面的 \ 是什么？它代表行继续操作符，当定义的宏不能用一行表达完整时，可以用"\"表示下一行继续此宏的定义。还有下边我们用到的 ## 是一个符号连接操作符它是用于连接作用。

JTKMOCK_SINGLETON_CATEGORY_DECLARE 这个是声明分类宏
JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT 这个是实现宏

接下来我们继续往下看

```

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
```
定义了三个类方法：
-  ####JTKCreateClassMock
- ####JTKCreatePartialMock
- ####JTKReleaseMock

####Mock类型分为ClassMock，PartialMock
1. ClassMock
如果你不想stub很多方法，而且不会在一个没有stub掉的方法被调用的时候抛出异常可以使用ClassMock。
2. PartialMock
如果没有stub掉的方法被调用了，这个方法会被转发到真实的对象上。这是对mock技术上的欺骗，但是非常有用，当有一些类不适合让自己很好的被stub时可以用PartialMock。

下面我们看实现代码：
首先创建一个静态全局变量在测试中我们可以使用此对象
```
#define JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT(__className,__sharedMethod)    \

static __className *mock_singleton_##__className = nil;                     \
\
@implementation __className (UnitTest)                                      \
\
+ (instancetype)__sharedMethod {                                            \
if (mock_singleton_##__className) return mock_singleton_##__className;  \
return invokeSupersequentNoParameters();                             \
}   
```

此时 ## 起到连接变量名作用
```

例：
JTKMOCK_SINGLETON_CATEGORY_IMPLEMENT（CDUserManager，sharedManager）

宏展开后：
static CDUserManager *mock_singleton_CDUserManager = nil;                     
@implementation CDUserManager (UnitTest)                                      
+ (instancetype) sharedManager {                                            
if (mock_singleton_CDUserManager) return mock_singleton_CDUserManager;  
return invokeSupersequentNoParameters();                             
} 
```
我们看一下sharedManager
```
if (mock_singleton_CDUserManager) return mock_singleton_CDUserManager;
return invokeSupersequentNoParameters(); 
首先判断一下是否有mock对象，如果有则返回mock对象没有则调用return

```
invokeSupersequentNoParameters它是一个宏，其作用是利用runtime查找原始实现方法IMP指针，然后调用原始单例生成对象。在这里调用此宏目的是如果原始的sharedManage的方法有所变动此宏也不用改动任何代码，不用维护相同的俩套单例代码详细原理在[Matt大神的文章](http://www.cocoawithlove.com/2008/03/supersequent-implementation.html)中可以找到它。

下面是分别创建ClassMock与PartialMock对象，具体用法详见Demo。
```
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
```
- 如果调用宏 JTKMOCK_SINGLETON 提示 Too many arguments to function call,expected 0,have 2,请打开你的测试工程的target，找到Build Setting下的Enable Strict Checking of objc_mesSend Calls,设置为NO
- 好至此宏代码分析完了下面我们新建个Demo看看如何使用去测试单例方法。

```
#import <XCTest/XCTest.h>
#import "HQYBaseTestCase.h"
#import "HQYSharedManager.h"
#import "ViewController.h"

//用category重写主类中的方法会有一个警告用以下代码包装去除
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
   // 这里使用PartialMock
    [HQYSharedManager JTKCreatePartialMock:[HQYSharedManager sharedManager]];

   // 然后使用mock后的对象sutb掉loadCurrentUserName让其返回我们期望值
    OCMStub([mock_singleton_HQYSharedManager loadCurrentUserName]).andReturn(@"stub success");
    
}
// 清空
- (void)tearDown {
    _vc = nil;
    _vcMock = nil;
    [HQYSharedManager JTKReleaseMock];
    [super tearDown];
}
// Stub测试
- (void)testLoadCurrentUserName{
    NSString *userName = [[HQYSharedManager sharedManager] loadCurrentUserName];
    XCTAssertEqual(userName, @"stub success");
}
// 控制器测试
- (void)testViewControllerLoadUserName{
    [_vc settingUserName];
    XCTAssertTrue([_vc.currentUserName isEqualToString:@"stub success"],@"没有成功赋值 错误显示：%@",_vc.currentUserName);
}
@end

```
