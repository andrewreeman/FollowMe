//
//  NSArray+ArrayExtensions.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "NSArray+ArrayExtensions.h"

@implementation NSArray (ArrayExtensions)
-(BOOL)isEmpty {
    return [self count] == 0;
}
-(BOOL)hasItems {
    return ![self isEmpty];
}
@end
