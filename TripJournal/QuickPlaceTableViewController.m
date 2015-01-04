//
//  QuickPlaceTableViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 4/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "QuickPlaceTableViewController.h"
#import "TripsDatabase.h"
#import "NewPlaceViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface QuickPlaceTableViewController ()

@end

@implementation QuickPlaceTableViewController

NSMutableArray *placesJournal;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"QuickPlaceTableView"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.navigationItem.title = _selectedTrip.name;
    
    placesJournal = [[TripsDatabase database] placesJournal: [NSNumber numberWithLongLong:_selectedTrip.uniqueId]];
    NSLog(@"QuickPlace tripId = %lld", _selectedTrip.uniqueId);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [placesJournal count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    Place *place = [placesJournal objectAtIndex:indexPath.row];
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text = place.description;
    
    return cell;
}

#pragma mark - Table view delegate


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"newPlace"]) {
        Place *newPlace = [[Place alloc] init];
        newPlace.tripId = [NSNumber numberWithLongLong:_selectedTrip.uniqueId];
        UINavigationController *navigationController = segue.destinationViewController;
        NewPlaceViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        dvc.place = newPlace;
    } else if ([sender isEqual:_backButton]) {
        NSLog(@"Back button");
    }else {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        _selectedPlace = [placesJournal objectAtIndex:selectedIndexPath.row];
        NSLog(@"Selected Trip name = %@", _selectedPlace.name );
        NSLog(@"prepareForSegue tripId = %lld", _selectedPlace.uniqueId);
    }
}

- (IBAction)newPlaceMade:(UIStoryboardSegue *)unwindSegue {
    NewPlaceViewController *source = [unwindSegue sourceViewController];
    if (source.isPlaceSaved) {
        [placesJournal addObject:source.place];
        [self.tableView reloadData];
    }
}

@end
