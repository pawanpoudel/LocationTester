//
//  MDLocationManager.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDLocationManager.h"
#import "MDDataManager.h"
#import "MDTrip.h"
#import "MDLocation.h"

@interface MDLocationManager()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *locationUpdateStartTime;

- (void)saveTripDataForLocation:(CLLocation *)newLocation
                    oldLocation:(CLLocation *)oldLocation;
@end

@implementation MDLocationManager

#pragma mark - Accessors

- (NSDate *)locationUpdateStartTime {
    if (_locationUpdateStartTime != nil) {
        return _locationUpdateStartTime;
    }
    
    _locationUpdateStartTime = [NSDate date];
    return _locationUpdateStartTime;
}

#pragma mark - Clean up

- (void)dealloc {
    [[self locationManager] setDelegate:nil];
    _trip = nil;
    _locationUpdateStartTime = nil;
}
 
#pragma mark - Location methods

- (CLLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.purpose = @"Your current location is needed to record trips.";
    _locationManager.delegate = self;
    
    return _locationManager;
}

- (void)startRecordingTrip {
    [[self locationManager] startUpdatingLocation];
}

- (void)stopRecordingTrip {
    self.locationUpdateStartTime = nil;
    [self.locationManager stopUpdatingLocation];
    self.trip = nil;
    
	if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(locationManagerDidStopRecordingTrip:)]) {
            [self.delegate locationManagerDidStopRecordingTrip:self];
        }
	}
}

- (void)saveTripDataForLocation:(CLLocation *)newLocation
                    oldLocation:(CLLocation *)oldLocation
{
    MDDataManager *dataManager = [MDDataManager sharedDataManager];    
    MDLocation *location = [dataManager createLocationEntity];
    
    location.timestamp = newLocation.timestamp;
    location.latitude = @(newLocation.coordinate.latitude);
    location.longitude = @(newLocation.coordinate.longitude);
    location.horizontalAccuracy = @(newLocation.horizontalAccuracy);
    
    [self.trip addLocationsObject:location];
    
    // If the app crashes while still recording,
    // we'll still have a valid trip by setting the tripEndTime to current time here.
    self.trip.tripEndTime = [NSDate date];
    [dataManager saveContext];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation == nil || newLocation.horizontalAccuracy < 0) {
        return;
    }   
    
    [self saveTripDataForLocation:newLocation oldLocation:oldLocation];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:)]) {
            [self.delegate locationManager:self didUpdateToLocation:newLocation];
        }
    }    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [self.delegate locationManager:self didFailWithError:error];
        }
    }
}

@end
