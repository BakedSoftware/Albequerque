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
static NSString * TRANSIT_FORMAT = @"DataSets/%@/JourneyPlan?from=%f,%f&to=%f,%f&date=%@&apiKey=%@&format=json";

@interface Albequerque ()
{
    NSMutableData * currentData;
    AlbequerqueCallback currentCallback;
    NSUInteger statusCode;
    NSURLConnection * currentConnection;
    JSONDecoder *decoder;
    NSDateFormatter *dateFormatter;
    NSError * lastError;
}

- (NSString*)_closestDataSet:(CLLocationCoordinate2D)point;
- (id)_options:(NSDictionary*)options valueForKey:(NSString*)key orDefault:(id)value;

@end

@implementation Albequerque

@synthesize apiKey;

- (void)transitFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination withOptions:(NSDictionary *)options completionHandler:(AlbequerqueCallback)handler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decoder = [JSONDecoder decoder];
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    });
  currentCallback = handler;
    NSString * dataset = [self _closestDataSet:origin];
    NSString * date = [dateFormatter stringFromDate:[self _options:options valueForKey:AQDateKey orDefault:[NSDate new]]];
    NSMutableString * url = [NSMutableString stringWithFormat:TRANSIT_FORMAT, dataset, origin.latitude, origin.longitude, destination.latitude, destination.longitude, date, apiKey];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (key == AQMaxJourneysKey || key == AQWalkDistanceKey) {
            [url appendFormat:@"&%@=%d", key, [obj integerValue]];
        } else if (key == AQReturnMappingDataKey) {
            [url appendFormat:@"&%@=%@", AQReturnMappingDataKey, [obj boolValue] ? @"true" : @"false"];
        }
    }];
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
    NSArray * result = nil;
    NSDictionary * json = [decoder objectWithData:currentData];
    if (statusCode == 200) {
        static NSString * Journeys = @"Journeys";
        NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:[[json valueForKey:Journeys] count]];
        for (NSDictionary * journeyDict in [json valueForKey:Journeys]) {
            [results addObject:[[AlbequerqueResult alloc] initWithJSON:journeyDict]];
        }
        result = results;
    } else {
        static NSString * Domain = @"Albequerque";
        static NSString * CodeKeyPath = @"Status.Details.Code";
        static NSString * MessageKeyPath = @"Status.Details.Message";
        lastError = [NSError errorWithDomain:Domain code:[[json valueForKeyPath:CodeKeyPath][0] integerValue] userInfo:[NSDictionary dictionaryWithObject:[json valueForKeyPath:MessageKeyPath][0] forKey:NSLocalizedDescriptionKey]];
    }
    
    currentCallback(result);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error Occured: %@", error.debugDescription);
}

- (NSError*)error
{
    NSError * e = lastError;
    lastError = nil;
    return e;
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

- (id)_options:(NSDictionary *)options valueForKey:(NSString *)key orDefault:(id)value
{
    id optionValue = [options valueForKey:key];
    if (optionValue) {
        return optionValue;
    }
    return value;
}

@end
