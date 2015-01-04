//
//  NewPlaceViewController.h
//  Vagabound
//
//  Created by Nathan Condell on 6/27/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface NewPlaceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)savePlace:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) Place *place;
@property (nonatomic, assign, getter=isPlaceSaved) BOOL placeSaved;

@end
