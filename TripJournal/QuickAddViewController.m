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
@property (strong, nonatomic) NSDateFormatter *format;
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
        self.selectedMemory.placeId = [NSNumber numberWithLongLong:_selectedPlace.uniqueId];
        self.selectedMemory.name = _name.text;
        self.selectedMemory.description = _description.text;
        [[TripsDatabase database] addMemoryToJournal:self.selectedMemory];
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

- (IBAction)useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset)
        {
            [_imageView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
            if (!location) {
                UIAlertView *noLocationAlert = [[UIAlertView alloc] initWithTitle:@"No location data." message:@"Click on Set Location below to set the location of this photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [noLocationAlert show];
            }
            _selectedMemory.latlng = location.coordinate;
            NSDate *retDate = [asset valueForProperty:ALAssetPropertyDate];
            //NSString *retDateString = [_format stringFromDate:retDate];
            _selectedMemory.date = retDate;
            //_memoryDate.text = retDateString;
        };
        
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:ALAssetsLibraryAssetForURLResultBlock
                failureBlock:^(NSError *error) {
                }];
        
        _selectedMemory.photo = [assetURL absoluteString];
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
