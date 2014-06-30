//
//  NewTripViewController.h
//  Vagabound
//
//  Created by Nathan Condell on 6/27/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface NewTripViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
- (IBAction)saveTrip:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) Trip *trip;
@property (nonatomic, assign, getter=isTripSaved) BOOL tripSaved;
@end
