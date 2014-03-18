//
//  SetLocationViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 3/15/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface SetLocationViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property CLLocationCoordinate2D latlng;
@end
