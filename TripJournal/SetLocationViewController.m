//
//  SetLocationViewController.m
//  TripJournal
//
//  Created by Nathan Condell on 3/15/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "SetLocationViewController.h"
#import "MemoryViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

static NSString *kCellIdentifier = @"cellIdentifier";

@interface SetLocationViewController ()

@end

@implementation SetLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"initWithNibName: bundle:");
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
    
    NSLog(@"SetLocationViewController viewDidLoad");
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"SetLocationView"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    
    _map.showsUserLocation = YES;
    //if (_latlng.latitude != 0 && _latlng.longitude != 0) {
    [self.map addAnnotation:[[MyAnnotation alloc] initWithTitle:@"Current selected location" andCoordinate:_latlng]];
    //}
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"SetLocationViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
    NSLog(@"startSearch");
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = self.map.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         NSLog(@"");
         NSMutableArray *places = [NSMutableArray array];
         for (MKMapItem *item in response.mapItems) {
             [places addObject:item.placemark];
         }
         [self.map removeAnnotations:[self.map annotations]];
         [self.map showAnnotations:places animated:NO];
     }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    NSLog(@"mapView: viewForAnnotation:");
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString *identifier = @"MyLocation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.draggable = YES;
        annotationView.canShowCallout = YES;
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        detailButton.tintColor = [UIColor darkGrayColor];
        annotationView.rightCalloutAccessoryView=detailButton;
        annotationView.image = [UIImage imageNamed:@"MyPoint.png"];
        annotationView.centerOffset = CGPointMake(0, -20);
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
    
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    NSLog(@"setCoordinate");
    _latlng = newCoordinate;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"mapView: annotationView: calloutAccessoryControlTapped:");
    _latlng = view.annotation.coordinate;
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
