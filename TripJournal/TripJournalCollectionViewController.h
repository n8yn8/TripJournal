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
#import "ELCImagePickerController.h"
#import <sqlite3.h>

@interface TripJournalCollectionViewController : UICollectionViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    NSMutableArray *_tripsJournal;
}


@property (nonatomic, retain) NSMutableArray *tripsJournal;
//@property NSMutableArray *journalEntries;
@property NSInteger chosenIndex;

- (IBAction)quickAdd:(id)sender;
@property (strong, nonatomic) NSMutableArray *urls;

- (IBAction)unwindToJournal:(UIStoryboardSegue *)unwindSegue;
- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue;

@end
