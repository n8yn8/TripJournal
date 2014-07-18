//
//  TripJournalAppDelegate.h
//  TripJournal
//
//  Created by Nathan Condell on 1/28/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface TripJournalAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<GAITracker> tracker;

@end
