//
//  Memory.m
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "Memory.h"

@implementation Memory

-(id)init {
    self.photo = @"";
    return self;
}

-(id)initWithUniqueId:(long long)uniqueId placeId:(NSNumber *)placeId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo date:(NSDate *)date latlng:(CLLocationCoordinate2D)latlng{
    if ((self = [super init])) {
        self.uniqueId = uniqueId;
        self.placeId = placeId;
        self.name = name;
        self.info = description;
        self.photo = photo;
        self.date = date;
        self.latlng = latlng;
    }
    return self;
}

-(void) dealloc {
    self.name = nil;
    self.info = nil;
    self.photo = nil;
    self.date = nil;
    //[super dealloc];
}

@end
