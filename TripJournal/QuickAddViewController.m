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

@interface QuickAddViewController ()

@end

@implementation QuickAddViewController

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
    // Do any additional setup after loading the view.
    
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
    if ([segue.identifier isEqualToString:@"Place"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        QuickPlaceTableViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        dvc.tripId = [NSNumber numberWithLongLong:_selectedTrip.uniqueId];
    } else if (sender == _headBack) {
        
    }
}

- (IBAction)unwindFromTripToQuick:(UIStoryboardSegue *)unwindSegue {
    QuickTripTableViewController *source = [unwindSegue sourceViewController];
    self.selectedTrip = source.selectedTrip;
    _tripName.text = self.selectedTrip.name;
    _tripDescription.text = self.selectedTrip.description;
    if (self.selectedTrip) {
        _setPlace.enabled = YES;
    }
}

- (IBAction)unwindFromPlaceToQuick:(UIStoryboardSegue *)unwindSegue {
    QuickPlaceTableViewController *source = [unwindSegue sourceViewController];
    self.selectedPlace = source.selectedPlace;
    _placeName.text = self.selectedPlace.name;
    _placeDescription.text = self.selectedPlace.description;
    if (_name.hasText) {
        _headBack.enabled = YES;
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
        _headBack.enabled = YES;
    } else {
        _headBack.enabled = NO;
    }
    return YES;
}


- (IBAction)saveMemory:(id)sender {
    self.selectedMemory.placeId = [NSNumber numberWithLongLong:_selectedPlace.uniqueId];
    self.selectedMemory.name = _name.text;
    self.selectedMemory.description = _description.text;
    [[TripsDatabase database] addMemoryToJournal:self.selectedMemory];
}

- (IBAction)cancel:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
@end
