//
//  MemoryViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "MemoryViewController.h"

@interface MemoryViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveMemory;
@property (strong, nonatomic) NSString *currentImage;

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
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"mm-dd-yyyy"];
    
    _currentImage = _memory.photo;
    [_placeCoverSwitch setOn:[_currentPlaceCover isEqualToString:_currentImage]];
    [_tripCoverSwitch setOn:[_currentTripCover isEqualToString:_currentImage]];

    _imageView.image = [UIImage imageNamed:_currentImage];
    _memoryName.text = _memory.name;
    _memoryDescription.text = _memory.description;
    
    _memoryDate.text = [format stringFromDate:_memory.date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if (sender == self.saveMemory){
        if (self.memoryName.text > 0) {
            NSLog(@"Save Button, name field > 0, name field = %@.", self.memoryName.text);
            self.memory = [[Memory alloc]init];
            self.memory.name = self.memoryName.text;
            self.memory.description = self.memoryDescription.text;
            self.memory.photo = _currentImage;
            if (_placeCoverSwitch.isOn) {
                self.currentPlaceCover = _currentImage;
            }
            if (_tripCoverSwitch.isOn) {
                self.currentTripCover = _currentImage;
            }
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

/*
- (IBAction)useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
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
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appendPic = [NSString stringWithFormat:@"%@.png", _detailID];
        NSData *data = UIImagePNGRepresentation(image);
        NSString *tmpPathToFile = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@",documentsDirectory,appendPic]];
        if([data writeToFile:tmpPathToFile atomically:YES]){
            NSLog(@"Success");
        }
        else{
            NSLog(@"Fail");
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
*/
@end
