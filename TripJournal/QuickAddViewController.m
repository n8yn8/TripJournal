//
//  QuickAddViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 4/26/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "QuickAddViewController.h"
#import "QuickTripTableViewController.h"
#import "QuickPlaceTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TripsDatabase.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface QuickAddViewController ()

@end

@implementation QuickAddViewController

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"QuickAddView"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterMediumStyle];
    
    self.selectedMemory = [[Memory alloc] init];
    
    void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset)
    {
        [_imageView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        NSDate *retDate = [asset valueForProperty:ALAssetPropertyDate];
        
        _selectedMemory.latlng = location.coordinate;
        _selectedMemory.date = retDate;
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:_imageUrl
             resultBlock:ALAssetsLibraryAssetForURLResultBlock
            failureBlock:^(NSError *error) {
            }];
    _selectedMemory.photo = [_imageUrl absoluteString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (IBAction)cancelSelectionUnwind:(UIStoryboardSegue *)unwindSegue {
    
}

- (IBAction)unwindFromPlaceToQuick:(UIStoryboardSegue *)unwindSegue {
    
    
    QuickPlaceTableViewController *source = [unwindSegue sourceViewController];
    
    self.selectedTrip = source.selectedTrip;
    _tripName.text = self.selectedTrip.name;
    
    self.selectedPlace = source.selectedPlace;
    _placeName.text = self.selectedPlace.name;
    if (_name.hasText) {
        _saveButton.enabled = YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_name isFirstResponder] && [touch view] != _name) {
        [_name resignFirstResponder];
    } else if ([_description isFirstResponder] && [touch view] != _description) {
        [_description resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_name]) {
        [_description becomeFirstResponder];
    }
    if ([textField isEqual:_description]) {
        [_description resignFirstResponder];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = _name.text.length - range.length + string.length;
    //NSLog(@"length = %lu, name = %lu, range = %lu, string = %lu", length, (unsigned long)_name.text.length, (unsigned long)range.length, (unsigned long)string.length);
    //NSLog(@"length = %lu, name = %@, range = %lu, string = %@", (unsigned long)length, _name.text, (unsigned long)range.length, string);
    if (length > 0 && _selectedPlace) {
        _saveButton.enabled = YES;
    } else {
        _saveButton.enabled = NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (IBAction)saveMemory:(id)sender {
    self.selectedMemory.placeId = [NSNumber numberWithLongLong:_selectedPlace.uniqueId];
    self.selectedMemory.name = _name.text;
    self.selectedMemory.description = _description.text;
    [[TripsDatabase database] addMemoryToJournal:self.selectedMemory];
    [_saveButton setTitle:@"Memory Saved" forState:UIControlStateDisabled];
    _saveButton.enabled = NO;
}

@end
