//
//  JournalCollectionHeaderView.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface JournalCollectionHeaderView : UICollectionReusableView <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *JournalMapView;

@end
