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
@property (nonatomic, retain) NSMutableArray *memoriesJournal;
@property (strong, nonatomic) NSNumber *refID;
@property (nonatomic, strong) Place *selectedPlace;
@property (nonatomic, strong) NSString *placeCoverImage;
@property (nonatomic, strong) NSString *tripCoverImage;
@property (nonatomic, strong) PlacesCollectionHeaderView *headerView;
@property NSInteger chosenIndex;
- (IBAction)unwindToPlace:(UIStoryboardSegue *)unwindSegue;
@end
