//
//  Memory.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyAnnotation.h"

@interface Memory : NSObject {
    long long _uniqueId;
    NSNumber *_placeId;
    NSString *_name;
    NSString *_description;
    NSString *_photo;
    NSURL *_photoURL;
    NSDate *_date;
    CLLocationCoordinate2D _latlng;
}

@property (nonatomic, assign) long long uniqueId;
@property (copy, nonatomic) NSNumber *placeId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSURL *photoURL;
@property (copy, nonatomic) NSDate *date;
@property CLLocationCoordinate2D latlng;

- (id)initWithUniqueId:(long long)uniqueId placeId:(NSNumber *)placeId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo date:(NSDate *)date latlng:(CLLocationCoordinate2D)latlng;

@end
