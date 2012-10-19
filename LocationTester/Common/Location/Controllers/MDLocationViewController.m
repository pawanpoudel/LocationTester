//
//  MDLocationViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//


#import "MDLocationViewController.h"
#import "MDLocationManager.h"
#import "MDMapPoint.h"
#import <QuartzCore/QuartzCore.h>

@interface MDLocationViewController ()

@property (strong, nonatomic) MDLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MDLocationViewController

#pragma mark - Accessors

- (MDLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[MDLocationManager alloc] init];
    return _locationManager;
}

#pragma mark - View lifecycle

- (void)addSegmentedControl {
    // Use a segmented control as the custom title view
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil]];
    
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 270, 30);
    segmentedControl.selectedSegmentIndex = 0;
    
	[segmentedControl addTarget:self
                         action:@selector(setMapType:)
               forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
}

- (void)addBarButtons {
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refreshLocation:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = navButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSegmentedControl];
    [self addBarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self refreshLocation:nil];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (NSString *)getAddressFromPlacemark:(CLPlacemark *)placemark {
    NSMutableString *address = [[NSMutableString alloc] init];
    
    // Street number
    if (placemark.subThoroughfare) {
        [address appendFormat:@"%@ ", placemark.subThoroughfare];
    }
    
    // Street name
    if (placemark.thoroughfare) {
        [address appendFormat:@"%@ ", placemark.thoroughfare];
    }
    
    // City
    if (placemark.locality) {
        [address appendFormat:@"%@ ", placemark.locality];
    }
    
    // State
    if (placemark.administrativeArea) {
        [address appendFormat:@"%@ ", placemark.administrativeArea];
    }
    
    // Zip
    if (placemark.postalCode) {
        [address appendFormat:@"%@", placemark.postalCode];
    }
    
    return address;
}

- (void)setMapType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;  
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

- (void)resetMapView {
    // Zoom out
    CLLocation *currentLocation = self.mapView.userLocation.location;
    if (currentLocation != nil) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 25000, 25000);
        [self.mapView setRegion:region animated:NO];        
    }
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    
    // Remove all annotations except the blue dot.    
    for (NSInteger i = 0; i < annotations.count; i++) {
        id <MKAnnotation> annotation = [annotations objectAtIndex:i];
        if ([annotation isMemberOfClass:[MKUserLocation class]] == YES) {
            [annotations removeObject:annotation];
        }
    }
    
    [self.mapView removeAnnotations:annotations];
}

//- (void)refreshLocation:(id)sender {
//    [self resetMapView];
//    
//    [[MDAppDelegate sharedAppDelegate] showProgressIndicator:@"Locating..."];
//    
//    [self.locationManager updateStreetAddressWithCompletionHandler:
//     ^(CLLocation *newLocation, CLPlacemark *newPlacemark, NSError *error) {         
//         [[MDAppDelegate sharedAppDelegate] hideProgressIndicator];
//         
//         if (newPlacemark != nil) {
//             NSString *title = [self getAddressFromPlacemark:newPlacemark];
//             NSString *subTitle = [NSString stringWithFormat:@"Accurate to %d meters", newLocation.horizontalAccuracy];
//             
//             MDMapPoint *mapPoint = [[MDMapPoint alloc] initWithCoordinate:newLocation.coordinate 
//                                                                     title:title 
//                                                                  subtitle:subTitle];
//             [self.mapView addAnnotation:mapPoint];
//             
//             // Zoom map to user's location
//             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 250, 250);
//             [self.mapView setRegion:region animated:YES];
//         }
//         else {
//             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We're Sorry" 
//                                                                 message:@"Your location couldn't be retrieved at this time. Please try again later."
//                                                                delegate:nil
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//             [alertView show];
//         }
//         
//        // Upload device's location to the server
//        [self.locationManager uploadLocation:newLocation];
//     }];
//}

#pragma mark - MKMapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)aMapView 
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // If it's the user location managed by the map view, return nil
    // so that a blue dot will be displayed.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;    
    }
    
    static NSString *DefaultAnnotationView = @"DefaultAnnotationView";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:DefaultAnnotationView];  
    
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                                                         reuseIdentifier:DefaultAnnotationView];
    }
    
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    
    
    
}

@end
