//
//  TripJournalCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripJournalCollectionViewController.h"
#import "TripCollectionViewController.h"
#import "QuickAddViewController.h"
#import "Trip.h"
#import "TripsDatabase.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "PageCoverViewController.h"

@interface TripJournalCollectionViewController ()
@property (strong, nonatomic) NSDateFormatter *format;
@property (strong, nonatomic) NSMutableArray *annotations;
@end

@implementation TripJournalCollectionViewController

NSIndexPath *deletePath;

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
    NSLog(@"viewDidLoad");
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Home Screen"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.tripsJournal = [TripsDatabase database].tripsJournal;
    
    _chosenIndex = -1;
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterNoStyle];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.collectionView addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    deletePath = [self.collectionView indexPathForItemAtPoint:p];
    if (deletePath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Delete"
                              message: @"Delete the selected Trip?"
                              delegate: self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[theAlert buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        long long deleteIndex = [[self.tripsJournal objectAtIndex:deletePath.item] uniqueId];
        [self.tripsJournal removeObjectAtIndex:deletePath.item];
        [[TripsDatabase database] deleteTrip:deleteIndex];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //count the array
    return [_tripsJournal count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //referencing the attributes of our cell
    static NSString *identifier = @"TripCell";
    //start our virtual loop through the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //instantiate the imageview in each cell
    UIImageView *menuPhotoView = (UIImageView *)[cell viewWithTag:100];
    UILabel *tripName = (UILabel *)[cell viewWithTag:101];
    UILabel *tripDesc = (UILabel *)[cell viewWithTag:102];
    
    //assign the image
    
    Trip *info = [_tripsJournal objectAtIndex:indexPath.item];
    if (![info.photo isEqualToString:@""] /*|| ![info.photo isEqualToString:@"(null)"]*/) {
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            [menuPhotoView setImage:[UIImage imageWithCGImage:[myasset thumbnail]]];
            [menuPhotoView setContentMode:UIViewContentModeScaleAspectFit];
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"can't get image");
            
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:[NSURL URLWithString:info.photo]
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
    tripName.text = info.name;
    tripDesc.text = info.description;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        JournalCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JournalHeaderView" forIndexPath:indexPath];
        
        headerView.JournalMapView.showsUserLocation = YES;
        NSMutableArray *annotations = [[TripsDatabase database] tripsAnnotations];
        [headerView.JournalMapView showAnnotations:annotations animated:NO];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"JournalFooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if (![segue.identifier isEqualToString:@"QuickAdd"] && ![segue.identifier isEqualToString:@"feedback"]) {
        if ([segue.identifier isEqualToString:@"AddPhotos"]) {
            UINavigationController *navigationController = segue.destinationViewController;
            PageCoverViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
            dvc.urls = self.urls;
        } else {
            
            //Get destination view controller
            UINavigationController *navigationController = segue.destinationViewController;
            TripCollectionViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
            
            //If a Trip is selected. Otherwise +Trip was selected.
            if ([segue.identifier isEqualToString:@"TripDetails"]) {
                
                //Get item at selected path
                NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
                NSIndexPath *index = [indexPaths objectAtIndex:0];
                _chosenIndex = index.item;
                dvc.selectedTrip = [_tripsJournal objectAtIndex:index.item];
            } else if ([segue.identifier isEqualToString:@"AddTrip"]) {
                dvc.selectedTrip = [[Trip alloc] init];
                _chosenIndex = _tripsJournal.count;
            }
        }
    }
}

- (IBAction)quickAdd:(id)sender {
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 40;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissViewControllerAnimated:YES completion:^{[self processElcData:info];}];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processElcData: (NSArray *)info{
    _urls = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        NSURL *assetURL = [dict objectForKey:UIImagePickerControllerReferenceURL];
        [_urls addObject:assetURL];
	}
    [self performSegueWithIdentifier:@"AddPhotos" sender:self];
}



- (IBAction)unwindToJournal:(UIStoryboardSegue *)unwindSegue
{
    TripCollectionViewController *source = [unwindSegue sourceViewController];
    Trip *item = source.selectedTrip;
    if (source.newTrip || (source.editedTrip && (_chosenIndex == _tripsJournal.count))) {
        [self.tripsJournal addObject:item];
        [self.collectionView reloadData];
    } else if (source.editedTrip) {
        [self.tripsJournal replaceObjectAtIndex:_chosenIndex withObject:item];
        [self.collectionView reloadData];
    }
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    self.tripsJournal = [TripsDatabase database].tripsJournal;
    [self.collectionView reloadData];
}

- (IBAction)cancel:(UIStoryboardSegue *)unwindSegue {
    //Do nothing.
}

@end
