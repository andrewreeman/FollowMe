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
//#import "Presenter.h"

@class LocationDelegate;

@protocol Presenter <NSObject>

-(void)present:(NSString*)message FromLocationDelegate: (LocationDelegate*)delegate;

@end

@interface LocationDelegate : NSObject<CLLocationManagerDelegate>

typedef void (^LocationUpdatedListener) (CLLocation* location);
typedef enum LocationUsages {
    ALWAYS,
    IN_APP
} LocationUsage;


-(void)setPresenter:(NSObject<Presenter>*)presenter;
-(void)setLocationUpdatedListener:(LocationUpdatedListener)listener;
-(void)startUpdatingLocation:(LocationUsage)usage;
-(void)checkAuthorisation:(LocationUsage)usage;
@end

#endif /* LocationDelegate_h */
