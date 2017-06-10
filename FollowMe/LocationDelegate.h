//
//  LocationDelegate.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#ifndef LocationDelegate_h
#define LocationDelegate_h

#import <CoreLocation/CoreLocation.h>


/**
 This class will simply report location updates to its listener.
 When the location usage changes it will require permission to continue updating in the background or not.
*/

@class LocationDelegate;

/**
 The presenter is used to display messages from the LocationDelegate to the user
*/
@protocol LocationMessagePresenter <NSObject>

-(void)present:(NSString*)message FromLocationDelegate: (LocationDelegate*)delegate;

@end

@interface LocationDelegate : NSObject<CLLocationManagerDelegate>

typedef void (^LocationUpdatedListener) (CLLocation* location);
typedef enum LocationUsages {
    ALWAYS,
    IN_APP
} LocationUsage;


-(void)setPresenter:(NSObject<LocationMessagePresenter>*)presenter;
-(void)setLocationUpdatedListener:(LocationUpdatedListener)listener;
-(void)startUpdatingLocation:(LocationUsage)usage;
-(void)checkAuthorisation:(LocationUsage)usage;
-(void)stop;
@end

#endif /* LocationDelegate_h */
