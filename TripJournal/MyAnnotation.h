//
//  MyAnnotation.h
//  TripJournal
//
//  Created by Nathan Condell on 2/11/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
- (id)initWithTitle:(NSString *)title andCoordinate: (CLLocationCoordinate2D)coordinate;
@end