//
//  Memory.m
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "Memory.h"

@implementation Memory

-(id)initWithUniqueId:(int)uniqueId placeId:(NSNumber *)placeId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo date:(NSDate *)date {
    if ((self = [super init])) {
        self.uniqueId = uniqueId;
        self.placeId = placeId;
        self.name = name;
        self.description = description;
        self.photo = photo;
        self.date = date;
    }
    return self;
}

-(void) dealloc {
    self.name = nil;
    self.description = nil;
    self.photo = nil;
    self.date = nil;
    //[super dealloc];
}

@end
