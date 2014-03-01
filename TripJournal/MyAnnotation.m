//
//  MyAnnotation.m
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize coordinate;

- initWithTitle:(NSString *)coordTitle andCoordinate:
(CLLocationCoordinate2D)coordinate2d{
    self.title = coordTitle;
    self.coordinate = coordinate2d;
    return self;
}

@end
