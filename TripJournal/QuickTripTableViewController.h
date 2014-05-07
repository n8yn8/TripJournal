//
//  QuickTripTableViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 4/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface QuickTripTableViewController : UITableViewController

@property (nonatomic, strong) Trip *selectedTrip;
- (IBAction)newTrip:(id)sender;

@end
