//
//  ViewController.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationDelegate.h"

/**
 This will show the users current location on the map complete with a toggle for selecting if they want tracking on or off.
*/

@interface PathViewController : UIViewController<LocationMessagePresenter>
    @property (nonnull, nonatomic) IBOutlet UIView* switchContainer;
    @property (nonnull, nonatomic) IBOutlet UILabel* trackingLabel;
    @property (nonnull, nonatomic) IBOutlet UISwitch* trackingSwitch;
    @property (strong, nonatomic) void (^ _Nullable completionHandler)(void);
@end

