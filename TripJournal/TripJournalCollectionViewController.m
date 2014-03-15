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
@property (strong, nonatomic) NSMutableArray *annotations;
@end

@implementation TripJournalCollectionViewController


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
    [_format setDateStyle:NSDateFormatterMediumStyle];
    [_format setTimeStyle:NSDateFormatterNoStyle];
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
    if (!([info.photo isEqualToString:@""])) {
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:info.photo];
        UIImage *myImage = [[UIImage alloc] initWithData:imageData];
        menuPhotoView.image = myImage;
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
    } else {
        dvc.selectedTrip = [[Trip alloc] init];
    }
}

- (IBAction)unwindToJournal:(UIStoryboardSegue *)unwindSegue
{
    TripCollectionViewController *source = [unwindSegue sourceViewController];
    Trip *item = source.selectedTrip;
    if (source.newTrip || (source.editedTrip && (_chosenIndex == -1))) {
        [self.tripsJournal addObject:item];
        [self.collectionView reloadData];
    }
    if (source.editedTrip && (_chosenIndex != -1)) {
        [self.tripsJournal replaceObjectAtIndex:_chosenIndex withObject:item];
        [self.collectionView reloadData];
    }
}

@end
