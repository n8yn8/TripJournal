//
//  TripCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripCollectionViewController.h"
#import "TripsDatabase.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TestFlight.h"

@interface TripCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSDateFormatter *format;

@end

@implementation TripCollectionViewController

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

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
	// Do any additional setup after loading the view.
    
    [TestFlight passCheckpoint:@"Trip View"];
    
    self.placesJournal = [[TripsDatabase database] placesJournal: [NSNumber numberWithLongLong:_selectedTrip.uniqueId]];
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterNoStyle];
    _chosenIndex = -1;
    _tripCoverImage = _selectedTrip.photo;
    
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
                              message: @"Delete the selected Place?"
                              delegate: self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[theAlert buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        long long deleteIndex = [[self.placesJournal objectAtIndex:deletePath.item] uniqueId];
        [self.placesJournal removeObjectAtIndex:deletePath.item];
        [[TripsDatabase database] deletePlace:deleteIndex];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //same as before….count the array
    return [_placesJournal count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //referencing the attributes of our cell
    static NSString *identifier = @"PlaceCell";
    //start our virtual loop through the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //instantiate the imageview in each cell
    UIImageView *menuPhotoView = (UIImageView *)[cell viewWithTag:200];
    UILabel *placeName = (UILabel *)[cell viewWithTag:201];
    UILabel *placeDesc = (UILabel *)[cell viewWithTag:202];
    //assign the image
    
    Place *place = [_placesJournal objectAtIndex:indexPath.row];
    if (!([place.photo isEqualToString:@""])) {
        
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
        [assetslibrary assetForURL:[NSURL URLWithString:place.photo]
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
    placeName.text = place.name;
    placeDesc.text = place.description;
    
    if (indexPath.item == 0) {
        _selectedTrip.startDate = place.startDate;
        _selectedTrip.endDate = place.endDate;
    } else {
        _selectedTrip.startDate = [_selectedTrip.startDate earlierDate:place.startDate];
        _selectedTrip.endDate = [_selectedTrip.endDate laterDate:place.endDate];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        _headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TripHeaderView" forIndexPath:indexPath];
        
        NSString *thisStartDate = [_format stringFromDate:_selectedTrip.startDate];
        NSString *thisEndDate = [_format stringFromDate:_selectedTrip.endDate];
        NSMutableString *tripDates;
        if (thisStartDate) {
            tripDates = [[NSMutableString alloc] initWithString:thisStartDate];
            if (thisEndDate) {
                [tripDates appendString:@" - "];
                [tripDates appendString:thisEndDate];
            }
        }
        _headerView.date.text = tripDates;
        _headerView.name.text = _selectedTrip.name;
        _headerView.description.text = _selectedTrip.description;
        
        if (!_headerView.name.hasText) {
            _placeAdd.enabled = NO;
            _headBack.title = @"Cancel";
        } else {
            _headBack.title = @"Save";
            _placeAdd.enabled = YES;
        }
        
        _headerView.TripMapView.showsUserLocation = YES;
        NSMutableArray *annotations = [[TripsDatabase database] placesAnnotations: [NSNumber numberWithLongLong:_selectedTrip.uniqueId]];
        [_headerView.TripMapView showAnnotations:annotations animated:NO];
        
        reusableview = _headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"TripFooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

#pragma mark - Navigation Control
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Prepare to save current state of current trip.
    //Test for edited trip or new trip.
    if (![self.headerView.name.text isEqualToString:@""]) {
        //There is something in the name field
        //NSLog(@"name is not blank");
        if (![self.selectedTrip.name isEqualToString: self.headerView.name.text] ||
            ![self.selectedTrip.description isEqualToString: self.headerView.description.text] ||
            ![self.selectedTrip.photo isEqualToString: _tripCoverImage] ||
            !(self.selectedTrip.latlng.latitude != self.tripCoord.latitude) /*||
            ![self.selectedTrip.startDate isEqualToDate:self.tempStartDate] ||
            ![self.selectedTrip.endDate isEqualToDate:self.tempEndDate]*/)
        {
            //Something is not what it used to be.
            //NSLog(@"a field was modified from the original.");
            
            if (!self.selectedTrip.name) {
                //This is a new trip.
                _newTrip = YES;
                _editedTrip = NO;
                self.selectedTrip.name = self.headerView.name.text;
                self.selectedTrip.description = self.headerView.description.text;
                self.selectedTrip.photo = _tripCoverImage;
                self.selectedTrip.latlng = _tripCoord;
                self.selectedTrip.uniqueId = [[TripsDatabase database] addTripToJournal:self.selectedTrip];
                //NSLog(@"New trip added to database with uniqueId = %lld", self.selectedTrip.uniqueId);
                
            } else {
                //This is an updated trip.
                _editedTrip = YES;
                _newTrip = NO;
                self.selectedTrip.name = self.headerView.name.text;
                self.selectedTrip.description = self.headerView.description.text;
                self.selectedTrip.photo = _tripCoverImage;
                self.selectedTrip.latlng = _tripCoord;
                [[TripsDatabase database] updateTrip:self.selectedTrip];
                //NSLog(@"Update the old one");
            }
            
        } else {
            //NSLog(@"Existing trip was not modified");
        }
    } else {
        //NSLog(@"New trip was not modified");
    }
    
    if (sender != self.saveButton) {
        //Get destination view controller
        UINavigationController *navigationController = segue.destinationViewController;
        PlacesCollectionViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        
        if ([segue.identifier isEqualToString:@"PlaceDetails"]) {
            
            //Get item at selected path
            NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
            NSIndexPath *index = [indexPaths objectAtIndex:0];
            _chosenIndex = index.item;
            dvc.selectedPlace = [_placesJournal objectAtIndex:_chosenIndex];
            dvc.tripCoverImage = self.tripCoverImage;
            
        } else if ([segue.identifier isEqualToString:@"NewPlace"]){
            _chosenIndex = _placesJournal.count;
            dvc.selectedPlace = [[Place alloc] init];
            dvc.selectedPlace.tripId = [NSNumber numberWithLongLong:self.selectedTrip.uniqueId];
            dvc.tripCoverImage = self.tripCoverImage;
        }
    }
}

- (IBAction)unwindToTrip:(UIStoryboardSegue *)unwindSegue
{
    PlacesCollectionViewController *source = [unwindSegue sourceViewController];
    Place *item = source.selectedPlace;
    
    if (![source.tripCoverImage isEqualToString:self.tripCoverImage]) {
        self.tripCoverImage = source.tripCoverImage;
        self.tripCoord = source.tripCoord;
    }
    
    if (source.newPlace || (source.editedPlace && (_chosenIndex == _placesJournal.count))) {
        [self.placesJournal addObject:item];
        [self.collectionView reloadData];
    }else if (source.editedPlace) {
        [self.placesJournal replaceObjectAtIndex:_chosenIndex withObject:item];
        [self.collectionView reloadData];
    }
    
}

#pragma mark - Touch Control
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_headerView.name isFirstResponder] && [touch view] != _headerView.name) {
        [_headerView.name resignFirstResponder];
    } else if ([_headerView.description isFirstResponder] && [touch view] != _headerView.description) {
        [_headerView.description resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_headerView.name]) {
        [_headerView.description becomeFirstResponder];
    }
    if ([textField isEqual:_headerView.description]) {
        [_headerView.description resignFirstResponder];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = _headerView.name.text.length - range.length + string.length;
    if (length > 0) {
        _placeAdd.enabled = YES;
        _headBack.title = @"Save";
    } else {
        _placeAdd.enabled = NO;
        _headBack.title = @"Cancel";
    }
    return YES;
}

@end
