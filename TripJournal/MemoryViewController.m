//
//  MemoryViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "MemoryViewController.h"
#import "TripsDatabase.h"
#import "SetLocationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TestFlight.h"

@interface MemoryViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveMemory;
@property (strong, nonatomic) NSString *currentImage;
@property (strong, nonatomic) NSDateFormatter *format;

@end

@implementation MemoryViewController

CLLocationManager *locationManager;
CLLocation *currentLocation;

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
	// Do any additional setup after loading the view.
    
    [TestFlight passCheckpoint:@"Memory View"];
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterMediumStyle];
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        [_imageView setImage:[UIImage imageWithCGImage:[myasset aspectRatioThumbnail]]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"can't get image");
        
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[NSURL URLWithString:_selectedMemory.photo]
                   resultBlock:resultblock
                  failureBlock:failureblock];
    
    _currentImage = _selectedMemory.photo;
    [_placeCoverSwitch setOn:[_currentPlaceCover isEqualToString:_currentImage]];
    [_tripCoverSwitch setOn:[_currentTripCover isEqualToString:_currentImage]];
    if ([_selectedMemory.photo isEqualToString:@""]) {
        _memoryDate.text = @"Choose a photo for this memory.";
        _shareButton.enabled = false;
    } else {
        _memoryDate.text = [_format stringFromDate:_selectedMemory.date];
    }
    _coord = _selectedMemory.latlng;
    _memoryName.text = _selectedMemory.name;
    if (!_selectedMemory.name) {
        _headBack.title = @"Cancel";
    }
    _memoryDescription.text = _selectedMemory.description;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if (sender == self.saveMemory){
        
        if (_placeCoverSwitch.isOn) {
            self.currentPlaceCover = _selectedMemory.photo;
            self.currentPlaceCoord = _coord;
        }
        if (_tripCoverSwitch.isOn) {
            self.currentTripCover = _selectedMemory.photo;
            self.currentTripCoord = _coord;
        }
        
        if (![self.memoryName.text isEqualToString:@""]) {
            //There is something in the name field
            //NSLog(@"name is not blank");
            if (![self.selectedMemory.name isEqualToString: self.memoryName.text] ||
                ![self.selectedMemory.description isEqualToString: self.memoryDescription.text] ||
                ![self.selectedMemory.photo isEqualToString:self.currentImage] ||
                (self.selectedMemory.latlng.latitude != self.coord.latitude))
            {
                //Something is not what it used to be.
                //NSLog(@"a field was modified from the original.");
                
                if (!self.selectedMemory.name) {
                    //This is a new trip.
                    _newMemory = YES;
                    _editedMemory = NO;
                    self.selectedMemory.name = self.memoryName.text;
                    self.selectedMemory.description = self.memoryDescription.text;
                    self.selectedMemory.latlng = self.coord;
                    self.selectedMemory.uniqueId = [[TripsDatabase database] addMemoryToJournal:self.selectedMemory];
                    //NSLog(@"New memory added to database with uniqueId = %lld", self.selectedMemory.uniqueId);
                } else {
                    //This is an updated trip.
                    _editedMemory = YES;
                    _newMemory = NO;
                    self.selectedMemory.name = self.memoryName.text;
                    self.selectedMemory.description = self.memoryDescription.text;
                    self.selectedMemory.latlng = self.coord;
                    [[TripsDatabase database] updateMemory:self.selectedMemory];
                    NSLog(@"Update the old memory");
                }
                
            } else {
                //NSLog(@"Existing memory was not modified");
            }
        } else {
            //NSLog(@"New memory was not modified");
        }
    } else if ([[segue identifier] isEqualToString:@"setLocation"]) {
        SetLocationViewController *dvc = segue.destinationViewController;
        dvc.latlng = _selectedMemory.latlng;
    }
}

- (IBAction)unwindToMemory:(UIStoryboardSegue *)unwindSegue
{
    SetLocationViewController *source = [unwindSegue sourceViewController];
    if ((source.latlng.latitude != _selectedMemory.latlng.latitude) || (source.latlng.longitude != _selectedMemory.latlng.longitude))
    {
        _coord = source.latlng;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_memoryName isFirstResponder] && [touch view] != _memoryName) {
        [_memoryName resignFirstResponder];
    } else if ([_memoryDescription isFirstResponder] && [touch view] != _memoryDescription) {
        [_memoryDescription resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_memoryName]) {
        [_memoryDescription becomeFirstResponder];
    }
    if ([textField isEqual:_memoryDescription]) {
        [_memoryDescription resignFirstResponder];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = _memoryName.text.length - range.length + string.length;
    if (length > 0) {
        _headBack.title = @"Save";
    } else {
        _headBack.title = @"Cancel";
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

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camera", @"Use Photo Roll", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
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
            _newPic = NO;
        }
    } else if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager startUpdatingLocation];
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
            _newPic = YES;
        }
    }
}

- (IBAction)share:(id)sender {
    
    NSMutableString *postText = [[NSMutableString alloc] initWithString:_memoryName.text];
    if (_memoryDescription.hasText) {
        [postText appendString:@" - "];
        [postText appendString:_memoryDescription.text];
    }
    
    UIImage *postImage = _imageView.image;
    
    NSArray *activityItems = @[postText, postImage];
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        if (_newPic) {
            _coord = (currentLocation.coordinate);
            NSDate *retDate = [NSDate date];
            NSString *retDateString = [_format stringFromDate:retDate];
            _selectedMemory.date = retDate;
            _memoryDate.text = retDateString;
            
            
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            _imageView.image = image;
            CGImageRef imageRef = image.CGImage;
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:imageRef metadata:[info objectForKey:UIImagePickerControllerMediaMetadata] completionBlock:^(NSURL *assetURL,NSError *error){
                if(error == nil)
                {
                    [self setRetreivedMemory:assetURL];
                    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"Save success!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"Save failure!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    NSLog(@"writeImage error: %@", error);
                    [alertView show];
                }
            }];
            
        } else {
            
            void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset)
            {
                [_imageView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
                [_imageView setContentMode:UIViewContentModeScaleAspectFit];
                CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                if (!location) {
                    UIAlertView *noLocationAlert = [[UIAlertView alloc] initWithTitle:@"No location data." message:@"Click on Set Location below to set the location of this photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [noLocationAlert show];
                }
                self.coord = location.coordinate;
                NSDate *retDate = [asset valueForProperty:ALAssetPropertyDate];
                NSString *retDateString = [_format stringFromDate:retDate];
                _selectedMemory.date = retDate;
                _memoryDate.text = retDateString;
            };
            
            NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:assetURL
                     resultBlock:ALAssetsLibraryAssetForURLResultBlock
                    failureBlock:^(NSError *error) {
                    }];
            [self setRetreivedMemory:assetURL];
            
        }
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)setRetreivedMemory:(NSURL *)assetURL {
    _selectedMemory.photo = [assetURL absoluteString];
    _shareButton.enabled = true;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
}


@end
