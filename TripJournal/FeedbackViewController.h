//
//  FeedbackViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 5/6/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController
- (IBAction)sendFeedback:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *feedback;
@property (strong, nonatomic) IBOutlet UILabel *result;

@end
