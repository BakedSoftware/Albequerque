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

typedef void(^AlbequerqueCallback)(AlbequerqueResult* result);

@interface Albequerque : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, assign) NSUInteger maxWalkDistance;
@property (nonatomic, readonly) NSError *error;

+ (Albequerque*)sharedInstance;
- (void)transitFrom:(CLLocationCoordinate2D)origin
                          to:(CLLocationCoordinate2D)destination
           completionHandler:(AlbequerqueCallback)handler;

@end
