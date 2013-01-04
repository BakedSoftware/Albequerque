//
//  AlbequerqueTests.m
//  AlbequerqueTests
//
//  Created by Kayle Gishen on 1/1/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import "AlbequerqueTests.h"
#import "Albequerque.h"

#define KEY "KEY"

@interface AlbequerqueTests ()
{
    Albequerque * instance;
    NSConditionLock *lock;
}

@end

@implementation AlbequerqueTests

- (void)setUp
{
    [super setUp];
    instance = [Albequerque sharedInstance];
    instance.apiKey = @KEY;
    lock = [NSConditionLock new];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testGetTransitInstructions
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    CLLocationCoordinate2D Apple = CLLocationCoordinate2DMake(37.33064, -122.028983);
    CLLocationCoordinate2D StocktonSt = CLLocationCoordinate2DMake(37.78574, -122.406018);
    [instance transitFrom:Apple to:StocktonSt completionHandler:^(AlbequerqueResult *result) {
        STAssertNotNil(result, @"Result should not be nil");
        STAssertTrue(result.legs.count > 0, @"Result should have at least 1 leg");
        for (AlbequerqueLeg *leg in result.legs) {
            STAssertNotNil(leg.instructions, @"Leg should always have instructions");
            if (leg.mode == BUS || leg.mode == TRAIN || leg.mode == LIGHT_RAIL) {
                STAssertNotNil(leg.headSign, @"Head Sign should always be set for Bus and Rail");
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
