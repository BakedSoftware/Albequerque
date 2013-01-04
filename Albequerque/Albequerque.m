//
//  Albequerque.m
//  Albequerque
//
//  Created by Kayle Gishen on 1/1/13.
//  Copyright (c) 2013 Baked Software. All rights reserved.
//

#import "Albequerque.h"
#import <JSONKit/JSONKit.h>
#import <UIKit/UIKit.h>

static NSURL * BASE_URL =  nil;
static NSString * TRANSIT_FORMAT = @"DataSets/%@/JourneyPlan?from=%f,%f&to=%f,%f&date=%@&apiKey=%@&maxWalkDistanceMetres=%d&format=json";

@interface Albequerque ()
{
  NSMutableData * currentData;
  AlbequerqueCallback currentCallback;
  NSUInteger statusCode;
    NSURLConnection * currentConnection;
  JSONDecoder *decoder;
}

- (NSString*)_closestDataSet:(CLLocationCoordinate2D)point;

@end

@implementation Albequerque

@synthesize apiKey, maxWalkDistance;

- (void)transitFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination completionHandler:(AlbequerqueCallback)handler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decoder = [JSONDecoder decoder];
    });
  currentCallback = handler;
  NSString * dataset = [self _closestDataSet:origin];
    NSString * date = @"2013-01-03T15:47";
  NSString * url = [NSString stringWithFormat:TRANSIT_FORMAT, dataset, origin.latitude, origin.longitude, destination.latitude, destination.longitude, date, apiKey, maxWalkDistance];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:BASE_URL]];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - Singleton

+ (Albequerque*)sharedInstance
{
    static Albequerque * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [Albequerque new];
        _instance.maxWalkDistance = 2000;
        BASE_URL = [NSURL URLWithString:@"http://journeyplanner.jeppesen.com/JourneyPlannerService/V2/REST/"];
    });
    return _instance;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [currentData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  currentData = [NSMutableData new];
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)(response);
  statusCode = httpResponse.statusCode;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    AlbequerqueResult * result = nil;
    if (statusCode == 200) {
        NSDictionary * json = [decoder objectWithData:currentData];
        NSDictionary * journey = [json valueForKey:@"Journeys"][0];
        result = [[AlbequerqueResult alloc] initWithJSON:journey];
    }
    
    currentCallback(result);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error Occured: %@", error.debugDescription);
}

#pragma mark - Private Methods

- (NSString*)_closestDataSet:(CLLocationCoordinate2D)point
{
    static NSArray * DataSets = nil;
    static NSURL * DataSetsURL = nil;
    static NSString * Latitude = @"lat", * Longitude = @"lng";
    static NSString * Id = @"Id";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DataSetsURL = [NSURL URLWithString:[NSString stringWithFormat:@"DataSets?ApiKey=%@&format=json", apiKey] relativeToURL:BASE_URL];
        NSDictionary * response = [decoder objectWithData:[NSData dataWithContentsOfURL:DataSetsURL]];
        NSMutableArray * sets = [NSMutableArray new];
        static NSString * Centroid = @"Centroid";
        static NSString * Separator = @", ";
        
        for (NSDictionary * set in [response objectForKey:@"AvailableDataSets"]) {
            NSNumber * lat, * lng;
            NSArray *centroid = [[set objectForKey:Centroid] componentsSeparatedByString:Separator];
            lat = [NSNumber numberWithFloat:[centroid[0] floatValue]];
            lng = [NSNumber numberWithFloat:[centroid[1] floatValue]];
            [sets addObject:[NSDictionary dictionaryWithObjectsAndKeys:lat,Latitude,lng,Longitude,[set valueForKey:Id],Id,nil]];
        }
        DataSets = sets;
    });
    
    float dist = MAXFLOAT;
    NSString *closest = nil;
    for (NSDictionary * set in DataSets) {
        float dlat = point.latitude - [[set valueForKey:Latitude] floatValue];
        float dlon = point.longitude - [[set valueForKey:Longitude] floatValue];
        float d = dlat * dlat + dlon * dlon;
        if(d < dist) {
            dist = d;
            closest = [set valueForKey:Id];
        }
    }
    return closest;
}

@end
