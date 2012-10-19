//
//  MDTripViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDTripViewController.h"
#import "MDDataManager.h"
#import "MDTrip.h"

@interface MDTripViewController () {
    MDTrip *currentTrip;
}

@property (weak, nonatomic) IBOutlet UIButton *startRecordingTripButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordingTripButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLongLabel;

@property (strong, nonatomic) MDLocationManager *locationManager;

@end

@implementation MDTripViewController

#pragma mark - Accessors

- (MDLocationManager *)locationManager {
    if (_locationManager) {
        return _locationManager;
    }
    
    _locationManager = [[MDLocationManager alloc] init];
    _locationManager.delegate = self;
    
    return _locationManager;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Record Trip";
    
    self.stopRecordingTripButton.enabled = NO;
    self.stopRecordingTripButton.alpha = 0.5f;
}

#pragma mark - Actions

- (void)setupTrip {
    currentTrip = [[MDDataManager sharedDataManager] createTripEntity];
    currentTrip.tripStartTime = [NSDate date];
    
    self.locationManager.trip = currentTrip;
    [self.locationManager startRecordingTrip];
}

- (IBAction)startRecording:(id)sender {
    self.startRecordingTripButton.enabled = NO;
    self.startRecordingTripButton.alpha = 0.5f;
    
    self.stopRecordingTripButton.enabled = YES;
    self.stopRecordingTripButton.alpha = 1.0f;
    
    self.statusLabel.text = @"Recording...";
    self.statusLabel.textColor = [UIColor redColor];
    
    [self setupTrip];
}

- (IBAction)stopRecording:(id)sender {    
    self.startRecordingTripButton.enabled = YES;
    self.startRecordingTripButton.alpha = 1.0f;
    
    self.stopRecordingTripButton.enabled = NO;
    self.stopRecordingTripButton.alpha = 0.5f;
    
    self.statusLabel.text = @"Not Recording...";
    self.statusLabel.textColor = [UIColor darkGrayColor];
    
    [self.locationManager stopRecordingTrip];
    
    currentTrip.tripEndTime = [NSDate date];
    [[MDDataManager sharedDataManager] saveContext];
    
    currentTrip = nil;
}

#pragma mark - MDLocationManager delegate methods

- (void)locationManager:(MDLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation {
    if (newLocation) {
        NSString *format = @"Latitude: %+.5f\nLongitude: %+.5f\nHorizontal Accuracy: %+.5f\n";
        
        self.latLongLabel.text = [NSString stringWithFormat:format,
                                  newLocation.coordinate.latitude,
                                  newLocation.coordinate.longitude,
                                  newLocation.horizontalAccuracy];
    }
}

- (void)locationManagerDidStopRecordingTrip:(MDLocationManager *)locationManager {
    self.latLongLabel.text = @"Lat & Long will be displayed here.";
}

- (void)locationManager:(MDLocationManager *)locationManager didFailWithError:(NSError *)error {
    DebugLog(@"Error occurred while retrieving location data. Error: %@, %@", error, [error userInfo]);
}

@end
