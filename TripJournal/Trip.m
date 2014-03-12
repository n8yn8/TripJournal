//
//  Trip.m
//  TripJournal
//
//  Created by Nathan Condell on 2/18/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "Trip.h"

@implementation Trip

- (id)initWithUniqueId:(long long)uniqueId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if ((self = [super init])) {
        self.uniqueId = uniqueId;
        self.name = name;
        self.description = description;
        self.photo = photo;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

-(void) dealloc {
    self.name = nil;
    self.description = nil;
    self.photo = nil;
    self.startDate = nil;
    self.endDate = nil;
    //[super dealloc];
}

@end
