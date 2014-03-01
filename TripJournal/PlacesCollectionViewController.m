//
//  PlacesCollectionViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "PlacesCollectionViewController.h"

@interface PlacesCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *savePlace;
@property (strong, nonatomic) NSDateFormatter *format;

@end


@implementation PlacesCollectionViewController

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
    
    // Holds memories associated with the current place.
    _memoryEntries = [[NSMutableArray alloc] init];
    
    _chosenIndex = -1;
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateFormat:@"mm-dd-yyyy"];
    //NSString *dateString = [format stringFromDate:date];
    
    Memory *one = [[Memory alloc] init];
    one.name = @"Sun Pyramids";
    one.photo = @"Place-SunPyramid.png";
    one.description = @"North end overlook of Avenida de los Muertos.";
    one.date = [_format dateFromString:@"11-28-2013"];
    
    Memory *two = [[Memory alloc] init];
    two.name = @"From the top";
    two.photo = @"Place-FromTheTop.png";
    two.description = @"View from the top of the Sun Pyramid";
    two.date = [_format dateFromString:@"11-28-2013"];
    
    Memory *three = [[Memory alloc] init];
    three.name = @"Ruins";
    three.photo = @"Place-Ruins.png";
    three.description = @"The ruins on the North end next to the Sun Pyramids";
    three.date = [_format dateFromString:@"11-28-2013"];
    
    Memory *four = [[Memory alloc] init];
    four.name = @"Walking up";
    four.photo = @"Place-WalkingUp.png";
    four.description = @"There were many merchants selling all sorts of things. Gotta haggle them down in price!";
    four.date = [_format dateFromString:@"11-29-2013"];
    
    if ([_selectedPlace.name isEqualToString:@"Teotihuacan"]) {
        [_memoryEntries addObjectsFromArray:@[one,two,three,four]];
    }
    _placeCoverImage = _selectedPlace.photo;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //same as before….count the array
    return _memoryEntries.count;
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
    Memory *memory = [_memoryEntries objectAtIndex:indexPath.item];
    menuPhotoView.image = [UIImage imageNamed:memory.photo];
    memoryName.text = memory.name;
    memoryDesc.text = memory.description;
    
    // Compare dates of the memories to determine start date and end date.
    if (indexPath.item == 0) {
        _selectedPlace.startDate = memory.date;
        _selectedPlace.endDate = memory.date;
    } else {
        _selectedPlace.startDate = [_selectedPlace.startDate earlierDate:memory.date];
        //NSLog(@"Start date = %@",[_format stringFromDate:_selectedPlace.startDate]);
        _selectedPlace.endDate = [_selectedPlace.endDate laterDate:memory.date];
        //NSLog(@"End date = %@",[_format stringFromDate:_selectedPlace.endDate]);
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
         _headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PlacesHeaderView" forIndexPath:indexPath];
        NSString *placeDates = [[NSString alloc]initWithFormat:@"%@ - %@", [_format stringFromDate:_selectedPlace.startDate], [_format stringFromDate:_selectedPlace.endDate]];
        _headerView.date.text = placeDates;
        _headerView.name.text = _selectedPlace.name;
        _headerView.description.text = _selectedPlace.description;
        _headerView.placeCoverImageView.image = [UIImage imageNamed:_placeCoverImage];
        
        reusableview = _headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //If a Trip is selected. Otherwise +Place was selected.
    if ([segue.identifier isEqualToString:@"MemoryDetails"]) {
        
        //Get destination view controller
        UINavigationController *navigationController = segue.destinationViewController;
		MemoryViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        
        //Get item at selected path
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        _chosenIndex = index.item;
        dvc.memory = [_memoryEntries objectAtIndex: _chosenIndex];
        dvc.currentPlaceCover = _placeCoverImage;
        dvc.currentTripCover = _tripCoverImage;
    } else if (sender == self.savePlace) {
        if (self.headerView.name.text > 0 ) {
            self.selectedPlace = [[Place alloc]init];
            self.selectedPlace.name = self.headerView.name.text;
            self.selectedPlace.description = self.headerView.description.text;
            self.selectedPlace.photo = _placeCoverImage;
        }
    }
}

- (IBAction)unwindToPlace:(UIStoryboardSegue *)unwindSegue
{
    MemoryViewController *source = [unwindSegue sourceViewController];
    Memory *item = source.memory;
    NSLog(@"Chosen index = %i", _chosenIndex);
    
    // If an existing memory was chosen
    if (_chosenIndex >= 0) {
        
        // If the the chosen memory was unchanged, do nothing.
        if ([item isEqual:[self.memoryEntries objectAtIndex:_chosenIndex]]){
            NSLog(@"returned memory is equal to selected memory");
        
        // Else update the chosen memory.
        } else {
            NSLog(@"returned memory is NOT equal to selected memory");
            [self.memoryEntries replaceObjectAtIndex:_chosenIndex withObject:item];
            [self.collectionView reloadData];
        }
        
        // Clear the index of the previously chosen memory.
        _chosenIndex = -1;
        
    }
    // Else the memory is a new memory. Save the new memory if it contains data.
    else if (item != nil) {
        NSLog(@"returned memory is a new memory");
        [self.memoryEntries addObject:item];
        [self.collectionView reloadData];
    }
    
    // If the returned item is marked but is not the previous cover photo
    if (![source.currentPlaceCover isEqualToString:_placeCoverImage]) {
        // Replace the current cover photo
        _placeCoverImage = source.currentPlaceCover;
    }
    if (![source.currentTripCover isEqualToString:_tripCoverImage]) {
        _tripCoverImage = source.currentTripCover;
    }
}

@end
