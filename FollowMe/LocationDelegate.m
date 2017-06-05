//
//  LocationDelegate.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationDelegate.h"

@implementation LocationDelegate
    typedef enum LocationUsages {
        ALWAYS,
        IN_APP
    } LocationUsage;

    CLLocationManager *m_manager;
    NSObject<Presenter> *m_presenter;


    // start updating location

    // set location updated callback

    // set location warning presenter

    // set location service backgroundUsage

- (LocationDelegate*)init
{
    self = [super init];
    if (self) {
        m_manager = [[CLLocationManager alloc]init];
        m_manager.delegate = self;
        m_manager.desiredAccuracy = kCLLocationAccuracyBest;
        m_manager.distanceFilter = 5.0f;
    }
    return self;
}

-(void)startUpdatingLocation:(LocationUsage)usage {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    switch(usage) {
        case IN_APP: {
            if ([m_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [m_manager requestWhenInUseAuthorization];
            }
            break;
        }
        case ALWAYS:{
            if ([m_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [m_manager requestAlwaysAuthorization];
            }
        }
    }
    [m_manager startUpdatingHeading];
}

// MARK: CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch(status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        default:
            break;
    }
}

@end

