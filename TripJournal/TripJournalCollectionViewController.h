//
//  TripJournalCollectionViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JournalCollectionHeaderView.h"
#import "MyAnnotation.h"
#import "TripCollectionViewController.h"

@interface TripJournalCollectionViewController : UICollectionViewController
@property NSMutableArray *journalEntries;
@property NSInteger chosenIndex;

- (IBAction)unwindToJournal:(UIStoryboardSegue *)unwindSegue;

@end
