//
//  Trip.h
//  TripJournal
//
//  Created by Nathan Condell on 2/18/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyAnnotation.h"

@interface Trip : NSObject {
    long long _uniqueId;
    NSString *_name;
    NSString *_description;
    NSString *_photo;
    NSDate *_startDate;
    NSDate *_endDate;
    CLLocationCoordinate2D _latlng;
}
@property (nonatomic, assign) long long uniqueId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSDate *startDate;
@property (copy, nonatomic) NSDate *endDate;
@property CLLocationCoordinate2D latlng;

- (id)initWithUniqueId:(long long)uniqueId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
