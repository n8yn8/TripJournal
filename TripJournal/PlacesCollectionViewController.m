//
//  PlacesCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "PlacesCollectionViewController.h"
#import "TripsDatabase.h"

@interface PlacesCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *savePlace;
@property (strong, nonatomic) NSDateFormatter *format;

@end


@implementation PlacesCollectionViewController

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
    
    self.memoriesJournal = [[TripsDatabase database] memoriesJournal:[NSNumber numberWithLongLong:_selectedPlace.uniqueId]];
    _chosenIndex = -1;
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterNoStyle];
    
    _placeCoverImage = _selectedPlace.photo;
    
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
                              message: @"Delete the selected Memory?"
                              delegate: self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[theAlert buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        long long deleteIndex = [[self.memoriesJournal objectAtIndex:deletePath.item] uniqueId];
        [self.memoriesJournal removeObjectAtIndex:deletePath.item];
        [[TripsDatabase database] deleteMemory:deleteIndex];
        [self.collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //same as before….count the array
    return _memoriesJournal.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //referencing the attributes of our cell
    static NSString *identifier = @"MemoryCell";
    //start our virtual loop through the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //instantiate the imageview in each cell
    UIImageView *menuPhotoView = (UIImageView *)[cell viewWithTag:300];
    UILabel *memoryName = (UILabel *)[cell viewWithTag:301];
    UILabel *memoryDesc = (UILabel *)[cell viewWithTag:302];
    //assign the image
    Memory *memory = [_memoriesJournal objectAtIndex:indexPath.item];
    if (!([memory.photo isEqualToString:@""])) {
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:memory.photo];
        UIImage *myImage = [[UIImage alloc] initWithData:imageData];
        menuPhotoView.image = myImage;
    }
    memoryName.text = memory.name;
    memoryDesc.text = memory.description;
    
    // Compare dates of the memories to determine start date and end date.
    if (indexPath.item == 0) {
        _tempStartDate = memory.date;
        _tempEndDate = memory.date;
    } else {
        _tempStartDate = [_tempStartDate earlierDate:memory.date];
        _tempEndDate = [_tempEndDate laterDate:memory.date];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        _headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PlacesHeaderView" forIndexPath:indexPath];
        
        NSString *thisStartDate = [_format stringFromDate:_selectedPlace.startDate];
        NSString *thisEndDate = [_format stringFromDate:_selectedPlace.endDate];
        NSMutableString *placeDates;
        if (thisStartDate) {
            placeDates = [[NSMutableString alloc] initWithString:thisStartDate];
            if (thisEndDate) {
                [placeDates appendString:@" - "];
                [placeDates appendString:thisEndDate];
            }
        }
        _headerView.date.text = placeDates;
        _headerView.name.text = _selectedPlace.name;
        _headerView.description.text = _selectedPlace.description;
        /*
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:_placeCoverImage];
        UIImage *myImage = [[UIImage alloc] initWithData:imageData];
        _headerView.placeCoverImageView.image = myImage;
         */
        
        reusableview = _headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"PlaceFooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Prepare to save current state of current trip.
    //Test for edited trip or new trip.
    if (![self.headerView.name.text isEqualToString:@""]) {
        //There is something in the name field
        //NSLog(@"name is not blank");
        if (![self.selectedPlace.name isEqualToString: self.headerView.name.text] ||
            ![self.selectedPlace.description isEqualToString: self.headerView.description.text] ||
            ![self.selectedPlace.photo isEqualToString:self.placeCoverImage] ||
            !(self.selectedPlace.latlng.latitude != self.placeCoord.latitude) ||
            ![self.selectedPlace.startDate isEqualToDate:self.tempStartDate] ||
            ![self.selectedPlace.endDate isEqualToDate:self.tempEndDate])
        {
            //Something is not what it used to be.
            //NSLog(@"a field was modified from the original.");
            
            if (!self.selectedPlace.name) {
                //This is a new place.
                _newPlace = YES;
                _editedPlace = NO;
                self.selectedPlace.name = self.headerView.name.text;
                self.selectedPlace.description = self.headerView.description.text;
                self.selectedPlace.photo = _placeCoverImage;
                self.selectedPlace.latlng = _placeCoord;
                self.selectedPlace.startDate = _tempStartDate;
                self.selectedPlace.endDate = _tempEndDate;
                self.selectedPlace.uniqueId = [[TripsDatabase database] addPlaceToJournal:self.selectedPlace];
                //NSLog(@"New place added to database with uniqueId = %lld", self.selectedPlace.uniqueId);
                
            } else {
                //This is an updated place.
                _editedPlace = YES;
                _newPlace = NO;
                self.selectedPlace.name = self.headerView.name.text;
                self.selectedPlace.description = self.headerView.description.text;
                self.selectedPlace.photo = _placeCoverImage;
                self.selectedPlace.latlng = _placeCoord;
                self.selectedPlace.startDate = _tempStartDate;
                self.selectedPlace.endDate = _tempEndDate;
                [[TripsDatabase database] updatePlace:self.selectedPlace];
                //NSLog(@"Update the old one");
            }
            
        } else {
            //NSLog(@"Existing place was not modified");
        }
    } else {
        //NSLog(@"New place was not modified");
    }
    
    if (sender != self.savePlace) {
        
        //Get destination view controller
        UINavigationController *navigationController = segue.destinationViewController;
        MemoryViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        
        if ([segue.identifier isEqualToString:@"MemoryDetails"]) {
            
            //Get item at selected path
            NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
            NSIndexPath *index = [indexPaths objectAtIndex:0];
            _chosenIndex = index.item;
            dvc.selectedMemory = [_memoriesJournal objectAtIndex: _chosenIndex];
            dvc.currentPlaceCover = self.placeCoverImage;
            dvc.currentTripCover = self.tripCoverImage;
        } else if ([segue.identifier isEqualToString:@"NewMemory"]) {
            dvc.selectedMemory = [[Memory alloc] init];
            dvc.selectedMemory.placeId = [NSNumber numberWithLongLong:self.selectedPlace.uniqueId];
            dvc.currentPlaceCover = self.placeCoverImage;
            dvc.currentTripCover = self.tripCoverImage;
        }
    }
}

- (IBAction)unwindToPlace:(UIStoryboardSegue *)unwindSegue
{
    MemoryViewController *source = [unwindSegue sourceViewController];
    Memory *item = source.selectedMemory;
    
    // If the returned item is marked but is not the previous cover photo
    if (source.placeCoverSwitch.isOn && ![source.currentPlaceCover isEqualToString:_placeCoverImage]) {
        // Replace the current cover photo
        _placeCoverImage = source.currentPlaceCover;
        _placeCoord = source.currentPlaceCoord;
    }
    if (source.tripCoverSwitch.isOn && ![source.currentTripCover isEqualToString:_tripCoverImage]) {
        _tripCoverImage = source.currentTripCover;
        _tripCoord = source.currentTripCoord;
    }
    
    if (source.newMemory) {
        [self.memoriesJournal addObject:item];
        [self.collectionView reloadData];
    }
    if (source.editedMemory) {
        [self.memoriesJournal replaceObjectAtIndex:_chosenIndex withObject:item];
        [self.collectionView reloadData];
    }
}

@end
