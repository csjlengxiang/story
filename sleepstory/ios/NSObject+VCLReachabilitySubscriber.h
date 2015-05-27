//
//  NSObject+VLReachabilityObject.h
//  VLReachability
//
//  Use this category to use a predfined set of VCLReachabilitySubscriber methods
//
//  Created by Adrian Maurer https://github.com/adrianmaurer on 5/9/14.
//

#import <Foundation/Foundation.h>
#import "VCLReachability.h"
#import "VCLReachabilitySubscriber.h"

@interface NSObject (VCLReachabilitySubscriber)

- (void)reachabilityChanged:(NSNotification *)note;
- (void)wifiReachabilityChanged:(NSNotification *)note;
- (void)internetReachabilityChanged:(NSNotification *)note;
- (void)hostNameReachabilityChanged:(NSNotification *)note;


@end
