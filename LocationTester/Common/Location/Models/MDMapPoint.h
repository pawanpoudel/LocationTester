//
//  MDMapPoint.h
//  MobileDefense
//
//  Created by Pawan Poudel on 4/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MDMapPoint : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
                   title:(NSString *)aTitle
                subtitle:(NSString *)aSubtitle;

@end