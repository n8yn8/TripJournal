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


@interface TripCollectionViewController : UICollectionViewController {
    NSMutableArray *_placesJournal;
}
@property (nonatomic, assign, getter=isEdited) BOOL editedTrip;
@property (nonatomic, assign, getter=isNewTrip) BOOL newTrip;
@property (nonatomic, retain) NSMutableArray *placesJournal;
@property (nonatomic, strong) Trip *selectedTrip;
@property (nonatomic, strong) TripCollectionHeaderView *headerView;
@property (nonatomic, strong) NSString *tripCoverImage;
@property CLLocationCoordinate2D tripCoord;
@property NSInteger chosenIndex;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *placeAdd;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *headBack;
- (IBAction)unwindToTrip:(UIStoryboardSegue *)unwindSegue;
@end
