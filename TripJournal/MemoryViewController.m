//
//  MemoryViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "MemoryViewController.h"
#import "TripsDatabase.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MemoryViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveMemory;
@property (strong, nonatomic) NSString *currentImage;
@property (strong, nonatomic) NSDateFormatter *format;

@end

@implementation MemoryViewController

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
    //[_format setTimeStyle:NSDateFormatterNoStyle];
    
    //if (_selectedMemory.photo) {
        //NSLog(@"%@", self.selectedMemory.photo);
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:self.selectedMemory.photo];
    /*
    } else if (_selectedMemory.photoURL) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:_selectedMemory.photoURL resultBlock:<#^(ALAsset *asset)resultBlock#> failureBlock:^(NSError *error)]
    }*/
    UIImage *myImage = [[UIImage alloc] initWithData:imageData];
    _imageView.image = myImage;
    
    _currentImage = _selectedMemory.photo;
    [_placeCoverSwitch setOn:[_currentPlaceCover isEqualToString:_currentImage]];
    [_tripCoverSwitch setOn:[_currentTripCover isEqualToString:_currentImage]];
    _coord = _selectedMemory.latlng;
    _memoryName.text = _selectedMemory.name;
    _memoryDescription.text = _selectedMemory.description;
    _memoryDate.text = [_format stringFromDate:_selectedMemory.date];
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
            NSLog(@"prepare for segue currentPlaceCover = %@", self.currentPlaceCover);
            
        }
        if (_tripCoverSwitch.isOn) {
            self.currentTripCover = _selectedMemory.photo;
            self.currentTripCoord = _coord;
            NSLog(@"prepare for segue currentTripCover = %@", self.currentTripCover);
        }
        
        if (![self.memoryName.text isEqualToString:@""]) {
            //There is something in the name field
            //NSLog(@"name is not blank");
            if (![self.selectedMemory.name isEqualToString: self.memoryName.text] ||
                ![self.selectedMemory.description isEqualToString: self.memoryDescription.text] ||
                ![self.selectedMemory.photo isEqualToString:self.currentImage])
            {
                //Something is not what it used to be.
               // NSLog(@"a field was modified from the original.");
                
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
                    //NSLog(@"Update the old one");
                }
                
            } else {
                //NSLog(@"Existing memory was not modified");
            }
        } else {
            //NSLog(@"New memory was not modified");
        }
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
        _newPic = NO;
    }
}

- (IBAction)useCamera:(id)sender {
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        //_imageURL = info[UIImagePickerControllerReferenceURL];
        _imageView.image = image;
        
        void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset)
        {
            
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
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
        
        //_selectedMemory.photoURL = assetURL;
        //NSLog(@"%@", [assetURL absoluteString]);
        
         //Writes a small version of selected pic to this app's sandbox.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appendPic = [NSString stringWithFormat:@"%@.png", [NSDate date]];
        NSData *data = UIImagePNGRepresentation(image);
        NSString *tmpPathToFile = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@",documentsDirectory,appendPic]];
        self.selectedMemory.photo = tmpPathToFile;
        if([data writeToFile:tmpPathToFile atomically:YES]){
            //NSLog(@"Success");
        }
        else{
            NSLog(@"Failed to write file");
        }
        if (_newPic)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        
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

@end
