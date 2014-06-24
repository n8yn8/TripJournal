//
//  QuickPlaceTableViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 4/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Trip.h"

@interface QuickPlaceTableViewController : UITableViewController

@property (nonatomic, strong) Trip *selectedTrip;
@property (nonatomic, strong) Place *selectedPlace;
- (IBAction)newPlace:(id)sender;

@end
