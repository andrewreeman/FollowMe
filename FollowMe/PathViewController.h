//
//  ViewController.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationDelegate.h"

@import GoogleMaps;

@interface PathViewController : UIViewController<LocationMessagePresenter>
    @property (nonnull, nonatomic) IBOutlet UIView* switchContainer;
    @property (nonnull, nonatomic) IBOutlet UILabel* trackingLabel;
    @property (nonnull, nonatomic) IBOutlet UISwitch* trackingSwitch;
@end

