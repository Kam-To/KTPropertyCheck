//
//  Tests.m
//  Tests
//
//  Created by Kam on 2021/4/27.
//

#import <XCTest/XCTest.h>
#import <KTPropertyCheck/KTPropertyCheck.h>
#import <UIKit/UIKit.h>

@interface Foo : NSObject
@property (nonatomic, assign) NSObject *bar;
@property (nonatomic, strong) NSObject *zoo;
@property (nonatomic, copy, getter=customBooVarGetter) NSObject *fooVar;
@property (nonatomic, unsafe_unretained) id unsafeReadonly;
@property (nonatomic, unsafe_unretained, readonly) NSObject *unsafeNotReadonly;
@end

@interface Foo ()
@property (nonatomic, unsafe_unretained) NSObject *parent;
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
    /*
     Check output by 👀
     KTPropertyCheck: ⚠️ parent in class: Foo
     KTPropertyCheck: ⚠️ bar in class: Foo
     KTPropertyCheck: ⚠️ unsafeReadonly in class: Foo
     */
    [KTPropertyCheck checkImagesThatContainClasses:@[Foo.class]];
}

@end
