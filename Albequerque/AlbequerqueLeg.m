//
//  AlbequerqueStep.m
//  Albequerque
//
//  Created by Kayle Gishen on 1/3/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import "AlbequerqueLeg.h"

static NSString * kMode = @"Mode";
static NSString * kBus = @"Bus";
static NSString * kTrain = @"Rail";
static NSString * kSubway = @"Subway";
static NSString * kLightRail = @"Light Rail";
static NSString * kFerry = @"Ferry";

static NSString * kOriginLocationDescription = @"OriginLocationDescription";
static NSString * kDestinationLocationDescription = @"DestinationLocationDescription";
static NSString * kDurationMinutes = @"DurationMinutes";
static NSString * kWalkDistanceMetres = @"WalkDistanceMetres";
static NSString * kRouteName = @"RouteName";

static NSString * kWalkFormat = @"Walk from %@ to %@";
static NSString * kGeneralFormat = @"Take %@ towards %@ (Head Sign: %@)";

@implementation AlbequerqueLeg

@synthesize mode, originDescription, destinationDescription, duration, routeName, headSign, startTime, instructions;

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        NSString *t = [json valueForKey:kMode];
        if ([t isEqualToString:kBus]) {
            mode = BUS;
        } else if ([t isEqualToString:kTrain]) {
            mode = TRAIN;
        } else if ([t isEqualToString:kLightRail]) {
            mode = LIGHT_RAIL;
        } else if ([t isEqualToString:kSubway]) {
            mode = SUBWAY;
        } else if ([t isEqualToString:kFerry]) {
            mode = FERRY;
        }else{
            mode = WALK;
        }
        
        originDescription = [json valueForKey:kOriginLocationDescription];
        destinationDescription = [json valueForKey:kDestinationLocationDescription];
        if (!destinationDescription)
            destinationDescription = @"Destination";
        
        duration = [[json valueForKey:kDurationMinutes] unsignedIntegerValue];
        
        if (mode != WALK) {
            routeName = [json valueForKey:kRouteName];
            instructions = [NSString stringWithFormat:kGeneralFormat, t, destinationDescription, headSign];
        } else {
            if (!originDescription) {
                instructions = [NSString stringWithFormat:@"Walk to %@", destinationDescription];
            } else {
                instructions = [NSString stringWithFormat:kWalkFormat, originDescription, destinationDescription];
            }
        }
    }
    
    return self;
}

@end
