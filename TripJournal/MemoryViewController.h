//
//  MemoryViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Memory.h"

@interface MemoryViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newPic;
- (IBAction)useCameraRoll:(id)sender;
@property (strong, nonatomic) NSURL *imageURL;
@property (nonatomic, strong) Memory *memory;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *memoryName;
@property (strong, nonatomic) IBOutlet UITextView *memoryDescription;
@property (strong, nonatomic) IBOutlet UILabel *memoryDate;
@property (strong, nonatomic) IBOutlet UISwitch *placeCoverSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *tripCoverSwitch;
@property (strong, nonatomic) NSString *currentPlaceCover;
@property (strong, nonatomic) NSString *currentTripCover;

@end
