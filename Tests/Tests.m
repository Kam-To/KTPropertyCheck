//
//  Tests.m
//  Tests
//
//  Created by Kam on 2021/4/27.
//

#import <XCTest/XCTest.h>
#import <KTPropertyCheck/KTPropertyCheck.h>

@interface Foo : NSObject
@property (nonatomic, assign) NSObject *bar;
@property (nonatomic, strong) NSObject *zoo;
@end
@implementation Foo
@end

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    [KTPropertyCheck checkImagesThatContainClasses:@[Foo.class]];
}

@end
