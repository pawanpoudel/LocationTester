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

@interface MDTripViewController () <UITextFieldDelegate> {
    MDTrip *currentTrip;
}

@property (weak, nonatomic) IBOutlet UIButton *startRecordingTripButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordingTripButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLongLabel;
@property (weak, nonatomic) IBOutlet UITextField *tripNameTextField;

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
    
    self.tripNameTextField.enabled = NO;
    self.tripNameTextField.alpha = 0.5f;
}

- (void)viewDidUnload {
    currentTrip = nil;
    [self setTripNameTextField:nil];
    [super viewDidUnload];
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
    
    self.tripNameTextField.enabled = NO;
    self.tripNameTextField.alpha = 0.5f;    
    
    self.statusLabel.text = @"Recording...";
    self.statusLabel.textColor = [UIColor redColor];
    
    [self setupTrip];
}

- (IBAction)stopRecording:(id)sender {
    self.startRecordingTripButton.enabled = YES;
    self.startRecordingTripButton.alpha = 1.0f;
    
    self.stopRecordingTripButton.enabled = NO;
    self.stopRecordingTripButton.alpha = 0.5f;
    
    self.tripNameTextField.enabled = YES;
    self.tripNameTextField.alpha = 1.0f;
    
    self.statusLabel.text = @"Not Recording...";
    self.statusLabel.textColor = [UIColor darkGrayColor];
    
    [self.locationManager stopRecordingTrip];
    
    currentTrip.tripEndTime = [NSDate date];
    currentTrip.name = [self getDefaultNameForTrip:currentTrip];
    [[MDDataManager sharedDataManager] saveContext];
    
    self.tripNameTextField.text = currentTrip.name;
}

#pragma mark - UITextFieldDelegate methods

- (NSString *)getDefaultNameForTrip:(MDTrip *)trip {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd--hh-mm-ss"];
    
    NSString *tripName = [NSString stringWithFormat:@"Trip_%@", [dateFormatter stringFromDate:trip.tripStartTime]];
    return tripName;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *tripName = nil;
    
    if ([textField.text length] > 0) {
        tripName = textField.text;
    }
    else {
        tripName = [self getDefaultNameForTrip:currentTrip];
    }
    
    textField.text = tripName;
    currentTrip.name = tripName;
    [[MDDataManager sharedDataManager] saveContext];
    
    return YES;
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
