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
    [instance transitFrom:Apple to:StocktonSt withOptions:nil completionHandler:^(NSArray *result) {
        STAssertNotNil(result, @"Result should not be nil");
        STAssertTrue(result.count == 3, @"There should be 3 journeys (default)");
        AlbequerqueResult * journey = result[0];
        STAssertTrue(journey.legs.count > 0, @"Result should have at least 1 leg");
        for (AlbequerqueLeg *leg in journey.legs) {
            STAssertNotNil(leg.instructions, @"Leg should always have instructions");
            if (leg.mode == BUS || leg.mode == TRAIN || leg.mode == LIGHT_RAIL) {
                STAssertNotNil(leg.headSign, @"Head Sign should always be set for Bus and Rail");
            }
            if (leg.mode != WALK) {
                STAssertNotNil(leg.departTime, @"Non Walking Leg should always have a DepartTime");
                STAssertNotNil(leg.arriveTime, @"Non Walking Leg should always have an ArriveTime");
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testGetTransitInstructionsWithMappingData
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    CLLocationCoordinate2D Apple = CLLocationCoordinate2DMake(37.33064, -122.028983);
    CLLocationCoordinate2D StocktonSt = CLLocationCoordinate2DMake(37.78574, -122.406018);
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], AQReturnMappingDataKey, nil];
    [instance transitFrom:Apple to:StocktonSt withOptions:options completionHandler:^(NSArray *result) {
        STAssertNotNil(result, @"Result should not be nil");
        AlbequerqueResult * journey = result[0];
        STAssertTrue(journey.legs.count > 0, @"Result should have at least 1 leg");
        for (AlbequerqueLeg *leg in journey.legs) {
            STAssertNotNil(leg.polyline, @"Leg should have polyline");
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testGetTransitInstructionsWithMaxWalkDistance
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    CLLocationCoordinate2D Apple = CLLocationCoordinate2DMake(37.33170312909739,-122.03077931202391);
    CLLocationCoordinate2D StocktonSt = CLLocationCoordinate2DMake(37.78574, -122.406018);
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:250], AQWalkDistanceKey, nil];
    [instance transitFrom:Apple to:StocktonSt withOptions:options completionHandler:^(NSArray *result) {
        STAssertNotNil(result, @"Result should not be nil");
        AlbequerqueResult * journey = result[0];
        STAssertTrue(journey.legs.count > 0, @"Result should have at least 1 leg");
        for (AlbequerqueLeg *leg in journey.legs) {
            if (leg.mode != WALK) {
                STAssertTrue(leg.walkDistance == 0, @"Non walking legs should have 0 walk distance");
            } else {
                STAssertTrue(leg.walkDistance < 250, @"Max walk distance is set to 250m");
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testGetTransitInstructionsWithMaxJourneys
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    CLLocationCoordinate2D Apple = CLLocationCoordinate2DMake(37.33170312909739,-122.03077931202391);
    CLLocationCoordinate2D StocktonSt = CLLocationCoordinate2DMake(37.78574, -122.406018);
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:5], AQMaxJourneysKey, nil];
    
    [instance transitFrom:Apple to:StocktonSt withOptions:options completionHandler:^(NSArray *result) {
        STAssertNotNil(result, @"Result should not be nil");
        STAssertTrue(result.count <= 5, @"Result should have at most 5 journeys");
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    semaphore = dispatch_semaphore_create(0);
    
    options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1], AQMaxJourneysKey, nil];
    [instance transitFrom:Apple to:StocktonSt withOptions:options completionHandler:^(NSArray *result) {
        STAssertNotNil(result, @"Result should not be nil");
        STAssertTrue(result.count <= 1, @"Result should have at most 1 journey");
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
