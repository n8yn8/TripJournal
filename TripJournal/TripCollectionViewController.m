//
//  TripCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripCollectionViewController.h"
#import "PlacesDatabase.h"

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
    
    _refID = [NSNumber numberWithInt:self.selectedTrip.uniqueId];
    NSLog(@"refID received is %@", _refID);
    self.placesJournal = [[PlacesDatabase database] placesJournal:_refID];
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateFormat:@"mm-dd-yyyy"];
    _chosenIndex = -1;
    /*
    Place *teo = [[Place alloc] init];
    teo.name = @"Teotihuacan";
    teo.photo = @"Place-SunPyramid.png";
    teo.description = @"The pyramidas outside of Mexico City.";
    teo.startDate = [_format dateFromString:@"Nov 28, 2013"];
    
    Place *coyo = [[Place alloc] init];
    coyo.name = @"Coyoacan";
    coyo.photo = @"Trip-Coyoacan.png";
    coyo.description = @"This part of the city is name after cayotes.";
    coyo.startDate = [_format dateFromString:@"Nov 29, 2013"];
    
    Place *art = [[Place alloc] init];
    art.name = @"Art Museum";
    art.photo = @"Trip-ArtMuseum.png";
    art.description = @"National Art Museum";
    art.startDate = [_format dateFromString:@"Nov 30, 2013"];
    
    Place *casa = [[Place alloc] init];
    casa.name = @"Casa Azul";
    casa.photo = @"Trip-CasaAzul.png";
    casa.description = @"The garden of Frida's house.";
    casa.startDate = [_format dateFromString:@"Dec 1, 2013"];
    
    Place *blank = [[Place alloc] init];
    blank.name = @"";
    blank.photo = @"";
    blank.description = @"";
    
    if ([_selectedTrip.name isEqualToString:@"Mexico City"]) {
        _placeEntries = [NSMutableArray arrayWithObjects:teo, coyo, art, casa, nil];
    }
     */
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
    menuPhotoView.image = [UIImage imageNamed:place.photo];
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
         
        CLLocationCoordinate2D mexicoCity = CLLocationCoordinate2DMake(19.4328, -99.1333);
        CLLocationCoordinate2D teotihuacan = CLLocationCoordinate2DMake(19.6925, -98.8438);
        CLLocationCoordinate2D coyoacan = CLLocationCoordinate2DMake(19.3500, -99.1617);
        CLLocationCoordinate2D casaAzul = CLLocationCoordinate2DMake(19.3550509, -99.1623655);
        CLLocationCoordinate2D artMuseum = CLLocationCoordinate2DMake(19.4361475, -99.1400875);
        MyAnnotation *mexCityAnnot = [[MyAnnotation alloc] initWithTitle: @"Mexico City" andCoordinate:mexicoCity];
        MyAnnotation *teoAnnot = [[MyAnnotation alloc] initWithTitle: @"Teotihuacan" andCoordinate:teotihuacan];
        MyAnnotation *coyoAnnot = [[MyAnnotation alloc] initWithTitle: @"Coyoacan" andCoordinate:coyoacan];
        MyAnnotation *casaAnnot = [[MyAnnotation alloc] initWithTitle: @"Casa Azul" andCoordinate:casaAzul];
        MyAnnotation *artAnnot = [[MyAnnotation alloc] initWithTitle: @"National Art Museum" andCoordinate:artMuseum];
        [_headerView.TripMapView showAnnotations:@[mexCityAnnot, teoAnnot, coyoAnnot, casaAnnot, artAnnot] animated:NO];
        
        reusableview = _headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"PlaceDetails"]) {
        
        
        UINavigationController *navigationController = segue.destinationViewController;
		PlacesCollectionViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        
        _chosenIndex = index.item;
        dvc.selectedPlace = [_placesJournal objectAtIndex:_chosenIndex];
        dvc.tripCoverImage = self.tripCoverImage;
        
    } else if (sender == self.saveButton){
        if (self.headerView.name.text > 0) {
            NSLog(@"Save Button, name field > 0, name field = %@.", self.headerView.name.text);
            self.selectedTrip = [[Trip alloc]init];
            self.selectedTrip.name = self.headerView.name.text;
            self.selectedTrip.description = self.headerView.description.text;
            self.selectedTrip.photo = _tripCoverImage;
        }
    }
}

- (IBAction)unwindToTrip:(UIStoryboardSegue *)unwindSegue
{
    PlacesCollectionViewController *source = [unwindSegue sourceViewController];
    Place *item = source.selectedPlace;
    
    if (_chosenIndex >= 0) {
        
        if ([item isEqual:[self.placesJournal objectAtIndex:_chosenIndex]]) {
            NSLog(@"returned place is equal to selected place.");
        } else {
            [self.placesJournal replaceObjectAtIndex:_chosenIndex withObject:item];
            [self.collectionView reloadData];
        }
        _chosenIndex = -1;
    } else if (item != nil) {
        [self.placesJournal addObject:item];
        [self.collectionView reloadData];
    }
    
    if (![source.tripCoverImage isEqualToString:self.tripCoverImage]) {
        self.tripCoverImage = source.tripCoverImage;
    }
}

@end
