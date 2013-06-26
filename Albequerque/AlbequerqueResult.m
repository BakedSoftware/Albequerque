//
//  AlbequerqueResult.m
//  Albequerque
//
//  Created by Kayle Gishen on 1/3/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import "AlbequerqueResult.h"
#import "AlbequerqueLeg.h"

static NSString * kDurationMinutes = @"DurationMinutes";
static NSString * kDepartTime = @"DepartTime";
static NSString * kArriveTime = @"ArriveTime";
static NSString * kLegs = @"Legs";

@implementation AlbequerqueResult

@synthesize departTime, arriveTime, duration, legs;

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm";
        departTime = [df dateFromString:[json valueForKey:kDepartTime]];
        arriveTime = [df dateFromString:[json valueForKey:kArriveTime]];
        duration = [[json valueForKey:kDurationMinutes] unsignedIntegerValue];
        NSMutableArray * parsedLegs = [NSMutableArray new];
        for (NSDictionary *legDict in [json valueForKey:kLegs]) {
            [parsedLegs addObject:[[AlbequerqueLeg alloc] initWithJSON:legDict]];
        }
        legs = parsedLegs;
    }
    
    return self;
}

@end
