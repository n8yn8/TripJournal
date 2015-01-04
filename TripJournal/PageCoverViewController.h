//
//  PageCoverViewController.h
//  TripJournal
//
//  Created by Nathan Condell on 5/12/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageCoverViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *urls;
@end
