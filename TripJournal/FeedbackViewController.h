//
//  FeedbackViewController.h
//  Vagabound
//
//  Created by Nathan Condell on 6/23/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)sendFeedback:(id)sender;
@end
