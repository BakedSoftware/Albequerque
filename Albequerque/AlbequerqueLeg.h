//
//  AlbequerqueStep.h
//  Albequerque
//
//  Created by Kayle Gishen on 1/3/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import <Foundation/Foundation.h>

enum AlbequerqueLegMode {
    WALK,
    BUS,
    TRAIN,
    LIGHT_RAIL,
    SUBWAY,
    FERRY,
    PRIVATE
    };

@interface AlbequerqueLeg : NSObject

@property (nonatomic, assign) enum AlbequerqueLegMode mode;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * headSign;
@property (nonatomic, retain) NSString * originDescription;
@property (nonatomic, retain) NSString * destinationDescription;
@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, readonly) NSString * instructions;
@property (nonatomic, readonly) NSString * polyline;
@property (nonatomic, readonly) NSUInteger walkDistance;

- (id)initWithJSON:(NSDictionary*)json;

@end
