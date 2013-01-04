//
//  Albequerque.h
//  Albequerque
//
//  Created by Kayle Gishen on 1/1/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import "AlbequerqueResult.h"
#import "AlbequerqueLeg.h"

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString * AQDateKey = @"date";
static NSString * AQWalkDistanceKey = @"maxWalkDistanceInMetres";
static NSString * AQMaxJourneysKey = @"maxJourneys";
static NSString * AQReturnMappingDataKey = @"MappingDataRequired";

typedef void(^AlbequerqueCallback)(NSArray* results);

@interface Albequerque : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, assign) NSUInteger maxWalkDistance;
@property (nonatomic, readonly) NSError *error;

+ (Albequerque*)sharedInstance;
- (void)transitFrom:(CLLocationCoordinate2D)origin
                 to:(CLLocationCoordinate2D)destination
        withOptions:(NSDictionary*)options
  completionHandler:(AlbequerqueCallback)handler;

@end
