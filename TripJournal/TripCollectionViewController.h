//
//  TripCollectionViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "Place.h"
#import "PlacesCollectionViewController.h"
#import "TripCollectionHeaderView.h"
#import "MyAnnotation.h"


@interface TripCollectionViewController : UICollectionViewController
@property (strong, nonatomic) NSNumber *refID;
@property (nonatomic, strong) Trip *selectedTrip;
@property (nonatomic, strong) NSMutableArray *placeEntries;
@property (nonatomic, strong) TripCollectionHeaderView *headerView;
@property (nonatomic, strong) NSString *tripCoverImage;
@property NSInteger chosenIndex;
- (IBAction)unwindToTrip:(UIStoryboardSegue *)unwindSegue;
@end
