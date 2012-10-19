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

typedef enum : NSUInteger {
    MDLocationRecordingMode,
    MDLocationSimulationMode,
    MDLocationNormalMode
} MDLocationMode;

@interface MDLocationManager()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) MDLocationMode locationMode;
@property (nonatomic) MDDataManager *dataManager;

@end

@implementation MDLocationManager

#pragma mark - Accessors

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

- (MDDataManager *)dataManager {
    return [MDDataManager sharedDataManager];
}

#pragma mark - Clean up

- (void)dealloc {
    self.locationManager.delegate = nil;
    _trip = nil;
}
 
#pragma mark - Location methods

- (void)startRecordingTrip {
    self.locationMode = MDLocationRecordingMode;
    [[self locationManager] startUpdatingLocation];
}

- (void)stopRecordingTrip {
    [self.locationManager stopUpdatingLocation];
    self.trip = nil;
    
	if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(locationManagerDidStopRecordingTrip:)]) {
            [self.delegate locationManagerDidStopRecordingTrip:self];
        }
	}
}

- (void)updateLocationWithTrip:(MDTrip *)trip {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortedLocations = [[trip.locations allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    CLLocation *newLocation = nil;
    CLLocation *oldLocation = nil;
    
    for (MDLocation *location in sortedLocations) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location.latitude doubleValue],
                                                                       [location.longitude doubleValue]);
        
        newLocation = [[CLLocation alloc] initWithCoordinate:coordinate
                                                    altitude:0
                                          horizontalAccuracy:[location.horizontalAccuracy doubleValue]
                                            verticalAccuracy:-1
                                                   timestamp:location.timestamp];
        
        [self locationManager:self.locationManager
          didUpdateToLocation:newLocation
                 fromLocation:oldLocation];
        
        oldLocation = newLocation;
    }    
}

- (void)startUpdatingLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isLocationSimulationOn = [defaults boolForKey:kMDLocationSimulationTurnedOn];
    
    if (isLocationSimulationOn) {
        self.locationMode = MDLocationSimulationMode;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *tripID = [defaults objectForKey:kMDUniqueIDOfTripToSimulate];
        
        if (IsEmpty(tripID)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Trip missing"
                                                                message:@"Looks like you forgot to select a trip to simulate."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        MDTrip *trip = [self.dataManager fetchTripWithID:tripID];
        [self updateLocationWithTrip:trip];
    }
    else {
        self.locationMode = MDLocationNormalMode;
        [self.locationManager startUpdatingLocation];
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
    
    switch (self.locationMode) {
        case MDLocationRecordingMode:
            [self saveTripDataForLocation:newLocation oldLocation:oldLocation];
            break;
            
        case MDLocationSimulationMode:
            break;
        
        case MDLocationNormalMode:
            break;
            
        default:
            break;
    }
    
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
