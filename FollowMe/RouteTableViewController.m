//
//  RouteTableViewController.m
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "RouteTableViewController.h"
#import "PathViewController.h"
#import "NSString+StringExtensions_m.m"
#import "FollowMe-Swift.h"

@import Toast;

@interface RouteTableViewController ()

@end

RouteTableDelegate* m_tableDelegate;
SerializableRoute* _Nullable  m_selectedRoute;

@implementation RouteTableViewController

-(void) viewDidLoad {
    m_selectedRoute = NULL;
    m_tableDelegate = [[RouteTableDelegate alloc]initWithPresenter:self AndDataSourceListener:
    ^(enum RouteDataSourceAction action, SerializableRoute * _Nonnull route) {
        switch(action) {
            case RouteDataSourceActionRouteDeleted:
            {
                NSString* message = [NSString stringWithFormat:
                                     [@"routeDeleted" localized], [[route routeMetaData] name]
                                     ];
                [[self view] makeToast:message];
                [self reload];
                break;
            }
            case RouteDataSourceActionRouteRenamed:
            {
                [self reload];
                break;
            }
            case RouteDataSourceActionRouteSelected:
            {
                m_selectedRoute = route;
                [self performSegueWithIdentifier:@"showStoredRouteSegue" sender:self];
            }
            default: break;
        }
    }];
    [[self m_routeTable] setDelegate:m_tableDelegate];
    [[self m_routeTable] setDataSource:m_tableDelegate];
    
    // init button
    [[self m_currentLocationBtn]setTitle:[@"startFollowing" localized] forState:UIControlStateNormal];
    [[self m_title]setText:[@"routes" localized]];
}

-(void) viewDidAppear:(BOOL)animated {
    [self reload];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* vc = segue.destinationViewController;
    
    if([vc isKindOfClass:[SelectedUserRouteViewController class]]) {
        SelectedUserRouteViewController* selectedRouteVC = (SelectedUserRouteViewController*)vc;
        
        [selectedRouteVC setRoute:m_selectedRoute];
    }
    else if( [vc isKindOfClass: [PathViewController class]]) {
        PathViewController* pathVC = (PathViewController*)vc;
        pathVC.completionHandler = ^{
            [self reload];
        };
    }
    
}

// MARK: RouteTableMessagePresenter methods
-(void)presentWithAlert:(UIAlertController * _Nonnull)Alert {
    [self presentViewController:Alert animated:true completion:nil];
}


// MARK: private methods
-(void) reload {
    [m_tableDelegate reloadData];
    [_m_routeTable reloadData];
}

@end
