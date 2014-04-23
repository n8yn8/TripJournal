//
//  QuickAddTableViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 4/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Trip.h"
#import "Place.h"
#import "Memory.h"

@interface QuickAddTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIView *name;
@property (strong, nonatomic) IBOutlet UITextField *description;
@property (nonatomic, strong) Trip *selectedTrip;
@property (strong, nonatomic) IBOutlet UILabel *tripName;
@property (strong, nonatomic) IBOutlet UILabel *tripDescription;
@property (nonatomic, strong) Place *selectedPlace;
@property (strong, nonatomic) IBOutlet UILabel *placeName;
@property (strong, nonatomic) IBOutlet UILabel *placeDescription;
- (IBAction)unwindFromTripToQuick:(UIStoryboardSegue *)unwindSegue;
- (IBAction)unwindFromPlaceToQuick:(UIStoryboardSegue *)unwindSegue;
- (IBAction)useCameraRoll:(id)sender;
@end
