//
//  TripCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripCollectionViewController.h"
#import "TripsDatabase.h"

@interface TripCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSDateFormatter *format;

@end

@implementation TripCollectionViewController

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
    
    self.placesJournal = [[TripsDatabase database] placesJournal: [NSNumber numberWithLongLong:_selectedTrip.uniqueId]];
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterNoStyle];
    _chosenIndex = -1;
    _tripCoverImage = _selectedTrip.photo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:place.photo];
        UIImage *myImage = [[UIImage alloc] initWithData:imageData];
        menuPhotoView.image = myImage;
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
        NSString *tripDates = [[NSString alloc]initWithFormat:@"%@ - %@", [_format stringFromDate:_selectedTrip.startDate], [_format stringFromDate:_selectedTrip.endDate]];
        _headerView.date.text = tripDates;
        _headerView.name.text = _selectedTrip.name;
        _headerView.description.text = _selectedTrip.description;
        
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

@end
