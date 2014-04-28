//
//  PlacesCollectionViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "PlacesCollectionHeaderView.h"
#import "MemoryViewController.h"
#import "Memory.h"

@interface PlacesCollectionViewController : UICollectionViewController
{
    NSMutableArray *_memoriesJournal;
}
@property (nonatomic, assign, getter=isEdited) BOOL editedPlace;
@property (nonatomic, assign, getter=isNewTrip) BOOL newPlace;
@property (nonatomic, retain) NSMutableArray *memoriesJournal;
@property (nonatomic, strong) Place *selectedPlace;
@property (nonatomic, strong) NSDate *tempStartDate;
@property (nonatomic, strong) NSDate *tempEndDate;
@property (nonatomic, strong) NSString *placeCoverImage;
@property (nonatomic, strong) NSString *tripCoverImage;
@property CLLocationCoordinate2D placeCoord;
@property CLLocationCoordinate2D tripCoord;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *memoryAdd;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *headBack;
@property (nonatomic, strong) PlacesCollectionHeaderView *headerView;
@property NSInteger chosenIndex;
- (IBAction)unwindToPlace:(UIStoryboardSegue *)unwindSegue;
@end
