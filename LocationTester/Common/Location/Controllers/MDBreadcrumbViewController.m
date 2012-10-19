//
//  MDBreadcrumbViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//
//  Note: Code in locationManager:didUpdateToLocation:fromLocation:
//  method is heavily borrowed from Apple's sample iOS project called
//  Breadcrumb (http://developer.apple.com/library/ios/#samplecode/Breadcrumb/Introduction/Intro.html)
//  Thank you Apple!

#import "MDBreadcrumbViewController.h"
#import "MDLocationManager.h"
#import "MDMapPoint.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <MapKit/MapKit.h>

#import <QuartzCore/QuartzCore.h>

@interface MDBreadcrumbViewController() <MKMapViewDelegate, MDLocationManagerDelegate> {
    CrumbPath *crumbs;
    CrumbPathView *crumbView;
}

@property (strong, nonatomic) MDLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MDBreadcrumbViewController

#pragma mark - Accessors

- (MDLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[MDLocationManager alloc] init];
    _locationManager.delegate = self;
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

- (void)addNavBarButtons {
    UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = navButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSegmentedControl];
    [self addNavBarButtons];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self.locationManager stopUpdatingLocation];
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

#pragma mark - MDLocationManager delegate methods

- (void)locationManager:(MDLocationManager *)locationManager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
		// Make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if (crumbs == nil) {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:crumbs];
                
                // On the first location update only, zoom map to user location
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.mapView setRegion:region animated:YES];
            }
            else {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                //
                MKMapRect updateRect = [crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect)) {
                    
                    // There is a non null update rect.
                    // Compute the currently visible map zoom scale
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                    
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    
                    // Ask the overlay view to update just the changed area.
                    [crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}

#pragma mark - MKMapView delegate methods

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if (crumbView == nil) {
        crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return crumbView;
}

@end
