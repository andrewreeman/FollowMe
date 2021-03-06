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

@import Toast;

@interface PathViewController ()

@end

@implementation PathViewController

// The google map api is partially hidden within this wrapper. This makes it potentially easy to change api in the future!
MapApi* m_mapApi;

// MARK: overloads
- (void)viewDidLoad {
    /** A note on the code style here:
     I could have broken up the commented sections into separate functions. But I explicitly only want this logic to happen here and never anywhere else. Refactoring into separate methods actually increases chances of bugs occurring.
     */
    [super viewDidLoad];
    
    // init map
    m_mapApi = [[MapApi alloc]init];
    UIView* map = (UIView*)[m_mapApi createMapWithFrame: self.view.frame];
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
    
    
    AppDelegate* app = [AppDelegate getApp];
    // init tracking: when updated will update ui
    [app startListeningToTrackingStateUsing:^(TrackingState newTrackingState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self trackingStateUpdated:newTrackingState];
        });
    }];
    
    
    // start location updates: when location updated will update the map location
    [app startLocationUpdatesUsingPresenter:self AndUiLocationUpdateListener:^
     (CLLocation *location, TrackingState trackingState)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(location != NULL) {
                [m_mapApi updateWithMap:map
                    ToLocation:location
                    WithTrackingState: trackingState
                ];
            }
        });
    }];
    
    // listen for when a route is complete
    [[app routeInteractor] setRouteUpdatedListenerWithRouteUpdatedListenerForObjC:
    ^(
      enum RouteFileStoreTransactionType transaction,
      SerializableRoute * _Nullable route,
      NSString * _Nullable error
    )
    {
        switch(transaction) {
            case RouteFileStoreTransactionTypeUpdate: {
                if( [[route routeMetaData] isComplete] ) {
                    [[self view] makeToast:[@"routeComplete" localized]];
                }
            }
                break;
            default: break;
        }
        
    }];
    
    // ensure tracking is off and refresh tracking state
    [[self trackingSwitch]setOn:NO];
    [self trackingToggleChanged:[self trackingSwitch]];
}

// MARK: actions

/**
 When the tracking toggle is changed we will inform the location tracking interactor that the state has been changed. This will inform the location update interactor of the new tracking state and also update the ui using the trackingStateUpdated method
*/
-(IBAction)trackingToggleChanged:(UISwitch*)sender {
    TrackingState newState = sender.isOn ? TrackingStateTrackingOn : TrackingStateTrackingOff;
    [[[AppDelegate getApp]locationTrackingInteractor]updateTrackingWithNewState:newState];
}

// MARK: LocationMessagePresenter methods

/**
 Used for presenting messages to the user from the LocationDelegate. These will mostly be about the authorisation status. Hence why we recheck the authorisation after OK has been tapped.
 This will essentially bug the user the turn on location!
*/
-(void)present:(NSString*)message FromLocationDelegate: (LocationDelegate*)delegate {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[@"followMe" localized] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:[@"ok" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LocationUpdatedInteractor* locationInteractor = [[AppDelegate getApp]locationUpdatedInteractor];
        [delegate checkAuthorisation: locationInteractor.locationUsage];
    }];
    
    [alert addAction:ok];    
    [self presentViewController:alert animated:true completion: nil];
}

-(IBAction)onBackTapped {
    [
     [[AppDelegate getApp]
      locationTrackingInteractor]updateTrackingWithNewState:TrackingStateTrackingOff
    ];
    [self dismissViewControllerAnimated:true completion:^{
        [[AppDelegate getApp] stopLocationUpdates];
       
        if( [self completionHandler] == NULL) { return; }
        [self completionHandler]();
    }];
}

// MARK: private methods

/**
 When the toggle is switched this tells the LocationTrackingInteractor (via the AppDelegate) that the tracking state has changed. This LocationTrackingInteractor will then inform the PathViewController that the tracking state has changed leading the label and the switch being updaed. 
*/
-(void)trackingStateUpdated:(TrackingState)newTrackingState {
    switch(newTrackingState) {
        case TrackingStateTrackingOn:
            [[self trackingLabel]setText:[@"trackingOn" localized]];
            if( ![[self trackingSwitch]isOn] ) {
                [[self trackingSwitch]setOn:YES animated:true];
            }
            break;
        default:
            [[self trackingLabel]setText:[@"trackingOff" localized]];
            
            if( [[self trackingSwitch]isOn] ) {
                [[self trackingSwitch]setOn:NO animated:true];
            }
            break;
    };
}


@end
