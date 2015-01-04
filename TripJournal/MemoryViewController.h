//
//  MemoryViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "Trip.h"
#import "Place.h"
#import "Memory.h"

@interface MemoryViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>

@property BOOL newPic;
@property (nonatomic, assign, getter=isEdited) BOOL editedMemory;

- (IBAction)showActionSheet:(id)sender;
@property (nonatomic, assign, getter=isNewTrip) BOOL newMemory;
- (IBAction)share:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *headBack;
@property (strong, nonatomic) Memory *selectedMemory;
@property (nonatomic, strong) Place *selectedPlace;
@property (nonatomic, strong) Trip *selectedTrip;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *memoryName;
@property (strong, nonatomic) IBOutlet UITextField *memoryDescription;
@property (strong, nonatomic) IBOutlet UILabel *memoryDate;
@property (strong, nonatomic) IBOutlet UISwitch *placeCoverSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *tripCoverSwitch;
@property (strong, nonatomic) NSString *currentPlaceCover;
@property (strong, nonatomic) NSString *currentTripCover;
@property CLLocationCoordinate2D currentPlaceCoord;
@property CLLocationCoordinate2D currentTripCoord;
@property CLLocationCoordinate2D coord;
- (IBAction)unwindToMemory:(UIStoryboardSegue *)unwindSegue;

@end
