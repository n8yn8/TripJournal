//
//  QuickTripTableViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 4/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "QuickTripTableViewController.h"
#import "TripsDatabase.h"
#import "Trip.h"
#import "QuickPlaceTableViewController.h"
#import "NewTripViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface QuickTripTableViewController ()

@end

@implementation QuickTripTableViewController

NSMutableArray *tripsJournal;

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
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"QuickTripTableView"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    
    tripsJournal = [TripsDatabase database].tripsJournal;
    
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
    return [tripsJournal count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell" forIndexPath:indexPath];
    Trip *trip = [tripsJournal objectAtIndex:indexPath.row];
    cell.textLabel.text = trip.name;
    cell.detailTextLabel.text = trip.description;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

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
    if ([segue.identifier isEqualToString:@"tripSelected"]){
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        _selectedTrip = [tripsJournal objectAtIndex:selectedIndexPath.row];
        NSLog(@"Selected Trip name = %@", _selectedTrip.name );
        NSLog(@"prepareForSegue tripId = %lld", _selectedTrip.uniqueId);
        UINavigationController *navigationController = segue.destinationViewController;
        QuickPlaceTableViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        dvc.selectedTrip = _selectedTrip;
    } else if ([segue.identifier isEqualToString:@"newTrip"]){
        Trip *newTrip = [[Trip alloc] init];
        UINavigationController *navigationController = segue.destinationViewController;
        NewTripViewController *dvc = [[navigationController viewControllers] objectAtIndex:0];
        dvc.trip = newTrip;
    }
}

- (IBAction)backToTrip:(UIStoryboardSegue *)unwindSegue {
}

- (IBAction)newTripMade:(UIStoryboardSegue *)unwindSegue {
    NewTripViewController *source = [unwindSegue sourceViewController];
    if (source.isTripSaved) {
        [tripsJournal addObject:source.trip];
        [self.tableView reloadData];
    }
}
@end
