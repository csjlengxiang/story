//
//  NSObject+VLReachabilityObject.m
//  VLReachability
//
//  Created by Adrian Maurer https://github.com/adrianmaurer on 5/9/14.
//


#import "NSObject+VCLReachabilitySubscriber.h"

@implementation NSObject (VCLReachabilitySubscriber)

#pragma mark - VLReachability Change

/*!
 * Called by VLReachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note
{
	VCLReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[VCLReachability class]]);
    
    [(id<VCLReachabilitySubscriber>)self updateWithReachability:curReach forType:nil];
}

/*!
 * Called by VLReachability whenever WiFi status changes.
 */
- (void)wifiReachabilityChanged:(NSNotification *)note
{
    VCLReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[VCLReachability class]]);
    
    // If a wifi specific callback is available call it
    if ([self respondsToSelector:@selector(updateWifiWithReachability:)]) {
        [(id<VCLReachabilitySubscriber>)self updateWifiWithReachability:curReach];
    } else {
        [(id<VCLReachabilitySubscriber>)self updateWithReachability:curReach forType:TYPE_WIFI];
    }

}

/*!
 * Called by VLReachability whenever Internet status changes.
 */
- (void)internetReachabilityChanged:(NSNotification *)note
{
    VCLReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[VCLReachability class]]);
    
    // If a internet specific callback is available call it
    if ([self respondsToSelector:@selector(updateInternetWithReachability:)]) {
        [(id<VCLReachabilitySubscriber>)self updateInternetWithReachability:curReach];
    } else {
        [(id<VCLReachabilitySubscriber>)self updateWithReachability:curReach forType:TYPE_INTERNET];
    }
}

/*!
 * Called by VLReachability whenever HostName status changes.
 */
- (void)hostNameReachabilityChanged:(NSNotification *)note
{
    VCLReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[VCLReachability class]]);
    
    // If a host name specific callback is available call it
    if ([self respondsToSelector:@selector(updateHostNameWithReachability:)]) {
        [(id<VCLReachabilitySubscriber>)self updateHostNameWithReachability:curReach];
    } else {
        [(id<VCLReachabilitySubscriber>)self updateWithReachability:curReach forType:TYPE_HOSTNAME];
    }
}

@end
