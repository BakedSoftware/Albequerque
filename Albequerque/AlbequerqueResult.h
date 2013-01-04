//
//  AlbequerqueResult.h
//  Albequerque
//
//  Created by Kayle Gishen on 1/3/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbequerqueResult : NSObject

@property (nonatomic, readonly) NSUInteger duration;
@property (nonatomic, readonly) NSDate * departTime;
@property (nonatomic, readonly) NSDate * arriveTime;
@property (nonatomic, readonly) NSArray * legs;

- (id)initWithJSON:(NSDictionary*)json;

@end
