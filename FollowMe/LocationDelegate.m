//
//  LocationDelegate.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationDelegate.h"
#import "NSString+StringExtensions_m.m"
#import "NSArray+ArrayExtensions.h"

@implementation LocationDelegate    
    CLLocationManager *m_manager;
    NSObject<LocationMessagePresenter> *m_presenter;
    LocationUpdatedListener m_locationUpdatedListener;
   
- (LocationDelegate*)init
{
    self = [super init];
    if (self) {
        m_manager = [[CLLocationManager alloc]init];
        m_manager.delegate = self;
        m_manager.desiredAccuracy = kCLLocationAccuracyBest;
        m_manager.distanceFilter = 1.0f;
    }
    return self;
}


// MARK: public methods


-(void)setPresenter:(NSObject<LocationMessagePresenter> *)presenter {
    m_presenter = presenter;
}

/**
 Will check location services is on and is not denied. Asks for permission where neccessary
*/
-(void)checkAuthorisation:(LocationUsage)usage {
    if (![CLLocationManager locationServicesEnabled]) {
        [self displayLocationDisabledMessage];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self displayLocationDeniedMessage];
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
}

/**
 The location updated listener will be called every time a new location is found
*/
-(void)setLocationUpdatedListener:(LocationUpdatedListener)listener {
    m_locationUpdatedListener = listener;
}

-(void)startUpdatingLocation:(LocationUsage)usage {
    [self checkAuthorisation:usage];
    [m_manager startUpdatingLocation];
}

// MARK: CLLocationManagerDelegate methods

/**
 Display message to the user if it's a status we don't like!
*/
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch(status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        case kCLAuthorizationStatusRestricted:
            [self displayLocationRestrictedMessage];
            break;
        case kCLAuthorizationStatusDenied:
            [self displayLocationDeniedMessage];
            break;
        default:
            break;
    }
}

/**
 Update listener with the most recent location
*/
-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    CLLocation* mostRecentLocation = [locations lastObject];
    NSLog(@"Updated location: %@", mostRecentLocation);
    if( mostRecentLocation != NULL && m_locationUpdatedListener != NULL ){
        m_locationUpdatedListener(mostRecentLocation);
    }
}

// MARK: private methods
- (void)displayLocationRestrictedMessage {
    [m_presenter present:[@"locationRestricted" localized] FromLocationDelegate:self];
}

-(void)displayLocationDeniedMessage {
    [m_presenter present:[@"locationDenied" localized] FromLocationDelegate:self];
}

-(void)displayLocationDisabledMessage {
    [m_presenter present:[@"locationDisabled" localized] FromLocationDelegate:self];
}

@end

