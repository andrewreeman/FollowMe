//
//  ViewController.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "PathViewController.h"
#import "AppDelegate.h"
#import "NSString+StringExtensions_m.m"

@interface PathViewController ()

@end

@implementation PathViewController

MapApi* m_mapApi;


// MARK: overloads
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init map
    AppDelegate* app = [AppDelegate getApp];
    m_mapApi = app.mapApi;
    GMSMapView* map = [m_mapApi createMapWithFrame: self.view.frame];
    map.center = self.view.center;
    [self.view addSubview:map];
    [self.view sendSubviewToBack:map];
 
    // init switch container
    UIColor* borderColor = [UIColor colorWithRed:117.0/255.0
                                           green:117.0/255.0
                                            blue:117.0/255.0
                                           alpha:1.0
                            ];
    
    [[self.switchContainer layer]setBorderColor: borderColor.CGColor];
    [[self.switchContainer layer]setBorderWidth:1.0];
    
    
    // init tracking
    [app startListeningToTrackingStateUsing:^(TrackingState newTrackingState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self trackingStateUpdated:newTrackingState];
        });
    }];
    
    
    // start location updates
    [app startLocationUpdatesUsingPresenter:self AndUiLocationUpdateListener:^
     (CLLocation *location, TrackingState trackingState)
    {
        if(location != NULL) {
            [m_mapApi updateWithMap:map ToLocation:location];
        }
    }];
    
    // ensure tracking is off and refresh tracking state
    [[self trackingSwitch]setOn:NO];
    [self trackingToggleChanged:[self trackingSwitch]];
}

// MARK: outlets
-(IBAction)trackingToggleChanged:(UISwitch*)sender {
    TrackingState newState = sender.isOn ? TrackingStateTrackingOn : TrackingStateTrackingOff;
    [[[AppDelegate getApp]locationTrackingInteractor]updateTrackingWithNewState:newState];
}

// MARK: LocationMessagePresenter methods
-(void)present:(NSString*)message FromLocationDelegate: (LocationDelegate*)delegate {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[@"followMe" localized] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:[@"ok" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LocationUpdatedInteractor* locationInteractor = [[AppDelegate getApp]locationUpdatedInteractor];
        [delegate checkAuthorisation: locationInteractor.locationUsage];
    }];
    
    [alert addAction:ok];    
    [self presentViewController:alert animated:true completion: nil];
}

// MARK: private methods
-(void)trackingStateUpdated:(TrackingState)newTrackingState {
    switch(newTrackingState) {
        case TrackingStateTrackingOn:
            [[self trackingLabel]setText:[@"trackingOn" localized]];
            break;
        case TrackingStateTrackingOff:
            [[self trackingLabel]setText:[@"trackingOff" localized]];
            break;
        case TrackingStateTrackingUndefined:
            [[self trackingLabel]setText:[@"trackingOff" localized]];
            break;
    };
}


@end
