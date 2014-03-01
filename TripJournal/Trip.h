//
//  Trip.h
//  TripJournal
//
//  Created by Nathan Condell on 2/18/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject
@property (strong, nonatomic) NSNumber *refID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *photo; //inferred
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *startDate; //inferred
@property (strong, nonatomic) NSDate *endDate; //inferred
@end
