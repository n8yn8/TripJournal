//
//  TripCollectionHeaderView.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface TripCollectionHeaderView : UICollectionReusableView <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet MKMapView *TripMapView;
@property (strong, nonatomic) IBOutlet UITextField *description;

@end
