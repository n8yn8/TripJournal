//
//  TripJournalCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripJournalCollectionViewController.h"
#import "TripCollectionViewController.h"
#import "Trip.h"
#import "TripsDatabase.h"

@interface TripJournalCollectionViewController ()
@property (strong, nonatomic) NSDateFormatter *format;
@end

@implementation TripJournalCollectionViewController

-(void)loadInitialData {
    
    
    /*
    Trip *mexicoCity = [[Trip alloc] init];
    mexicoCity.name = @"Mexico City";
    mexicoCity.photo = @"Place-SunPyramid.png";
    mexicoCity.description = @"Went here for my birthday";
    mexicoCity.startDate = [_format dateFromString:@"Nov 28, 2013"];
    mexicoCity.endDate = [_format dateFromString:@"Dec 1, 2013"];
    [self.journalEntries addObject:mexicoCity];
    
    Trip *argentina = [[Trip alloc] init];
    argentina.name = @"Argentina";
    argentina.photo = @"Main-Argentina.png";
    argentina.description = @"Impromptu trip";
    [self.journalEntries addObject:argentina];
    */
}

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
    self.tripsJournal = [TripsDatabase database].tripsJournal;
    
    _chosenIndex = -1;
    _format = [[NSDateFormatter alloc] init];
    [_format setDateFormat:@"mm-dd-yyyy"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    menuPhotoView.image = [UIImage imageNamed:info.photo];
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
        CLLocationCoordinate2D mexicoCity = CLLocationCoordinate2DMake(19.4328, -99.1333);
        CLLocationCoordinate2D buenosAires = CLLocationCoordinate2DMake(-34.6033, -58.3817);
        MyAnnotation *mcAnnot = [[MyAnnotation alloc] initWithTitle: @"Mexico City" andCoordinate:mexicoCity];
        MyAnnotation *baAnnot = [[MyAnnotation alloc] initWithTitle: @"Argentina" andCoordinate:buenosAires];
        [headerView.JournalMapView showAnnotations:@[mcAnnot,baAnnot] animated:NO];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //If a Trip is selected. Otherwise +Trip was selected.
    if ([segue.identifier isEqualToString:@"TripDetails"]) {
        
        //Get destination view controller
        UINavigationController *navigationController = segue.destinationViewController;
		TripCollectionViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        
        //Get item at selected path
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        
        _chosenIndex = index.item;
        dvc.selectedTrip = [_tripsJournal objectAtIndex:index.item];
        //dvc.refID = ;
    }
}

- (IBAction)unwindToJournal:(UIStoryboardSegue *)unwindSegue
{
    TripCollectionViewController *source = [unwindSegue sourceViewController];
    Trip *item = source.selectedTrip;
    NSLog(@"UndwindToJournal returned uniqueId = %i", item.uniqueId);
    
    if (_chosenIndex >= 0) {
        
        if ([item isEqual:[self.tripsJournal objectAtIndex:_chosenIndex]]) {
            NSLog(@"returned trip is equal to selected trip.");
        } else {
            NSLog(@"returned trip was edited.");
            [self.tripsJournal replaceObjectAtIndex:_chosenIndex withObject:item];
            [self.collectionView reloadData];
        }
        _chosenIndex = -1;
        
    } else if (item != nil) {
        NSLog(@"returned trip is new");
        [self.tripsJournal addObject:item];
        //[TripsDatabase database].addToJournal:item;
        [self.collectionView reloadData];
    }
}

@end
