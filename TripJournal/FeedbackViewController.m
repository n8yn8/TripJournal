//
//  FeedbackViewController.m
//  Vagabound
//
//  Created by Nathan Condell on 6/23/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "FeedbackViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

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
    NSLog(@"viewDidLoad FeedbackViewController");
    // Do any additional setup after loading the view.
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Feedback"];
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createScreenView] build]];
    /*
    [_allowAnalytics setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"allowTracking"]];
    NSLog(@"allowTracking read as %hhd", [[NSUserDefaults standardUserDefaults] boolForKey:@"allowTracking"]);
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     
 }
 */


- (IBAction)sendFeedback:(id)sender {
    NSLog(@"sendFeedback");
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Vagabound"];
    [controller setToRecipients:@[@"natecondell@gmail.com"]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*- (IBAction)toggleAllowAnalytics:(id)sender {
    NSLog(@"toggleAllowAnalytics");
    [[NSUserDefaults standardUserDefaults] setBool:_allowAnalytics.isOn forKey:@"allowTracking"];
    NSLog(@"allowTracking saved as %hhd", [[NSUserDefaults standardUserDefaults] boolForKey:@"allowTracking"]);
}*/
@end