//
//  Place.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject
@property (strong, nonatomic) NSNumber *refID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@end
