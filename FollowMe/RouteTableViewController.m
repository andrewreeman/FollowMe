//
//  RouteTableViewController.m
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "RouteTableViewController.h"
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
    m_tableDelegate = [[RouteTableDelegate alloc]init];
    [[self m_routeTable] setDelegate:m_tableDelegate];
    [[self m_routeTable] setDataSource:m_tableDelegate];
    
    m_tableDelegate.objCRouteSelected = ^(SerializableRoute * _Nonnull route) {
        m_selectedRoute = route;
        [self performSegueWithIdentifier:@"showStoredRouteSegue" sender:self];
    };
}

-(void) viewDidAppear:(BOOL)animated {
    [self reload];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[SelectedUserRouteViewController class]]) {
        SelectedUserRouteViewController* vc = (SelectedUserRouteViewController*)segue.destinationViewController;
        
        [vc setRoute:m_selectedRoute];
    }
}

-(void) reload {
    [m_tableDelegate reloadData];
    [_m_routeTable reloadData];
}

@end
