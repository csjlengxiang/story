/*
     File: VLReachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
  Version: 3.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 Modified by Adrian Maurer https://github.com/adrianmaurer
 
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

#import "VCLReachability.h"


NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";
NSString *kInternetReachabilityChangedNotification = @"kInternetReachabilityChangedNotification";
NSString *kWifiReachabilityChangedNotification = @"kWifiReachabilityChangedNotification";
NSString *kHostNameReachabilityChangedNotification = @"kHostNameReachabilityChangedNotification";

NSString* const TYPE_WIFI = @"WIFI";
NSString* const TYPE_INTERNET = @"INTERNET";
NSString* const TYPE_HOSTNAME = @"HOSTNAME";


#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags

    NSLog(@"VLReachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [VCLReachability class]], @"info was wrong class in ReachabilityCallback");

    VCLReachability* noteObject = (__bridge VCLReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: [noteObject notificationType] object: noteObject];
}


#pragma mark - VLReachability implementation

@implementation VCLReachability
{
	BOOL _alwaysReturnLocalWiFiStatus; //default is NO
	SCNetworkReachabilityRef _reachabilityRef;
    NSString* _notificationType;
}

#pragma mark - VLReachability Objects
static VCLReachability* _alwaysReachability;
static VCLReachability* _internetReachability;
static VCLReachability* _wifiReachability;
static NSMutableDictionary* _hostNames;

#pragma mark - Class methods
+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	VCLReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL)
	{
		returnValue= [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
            returnValue->_notificationType = kHostNameReachabilityChangedNotification;
		}
	}
	return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);

	VCLReachability* returnValue = NULL;

	if (reachability != NULL)
	{
		returnValue = [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
            
            if (!returnValue->_notificationType) {
                returnValue->_notificationType = kInternetReachabilityChangedNotification;
            }
		}
	}
	return returnValue;
}


+ (instancetype)reachabilityAlways
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
    VCLReachability* returnValue = [self reachabilityWithAddress: &zeroAddress];
    if (returnValue != NULL)
	{
        returnValue->_notificationType = kReachabilityChangedNotification;
	}
    
	return returnValue;
}


+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}


+ (instancetype)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	VCLReachability* returnValue = [self reachabilityWithAddress: &localWifiAddress];
	if (returnValue != NULL)
	{
		returnValue->_alwaysReturnLocalWiFiStatus = YES;
        returnValue->_notificationType = kWifiReachabilityChangedNotification;
	}
    
	return returnValue;
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
	{
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			returnValue = YES;
		}
	}
    
	return returnValue;
}


- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}


- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
	{
		CFRelease(_reachabilityRef);
	}
}


#pragma mark - Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
	NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		returnValue = ReachableViaWiFi;
	}
    
	return returnValue;
}


- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// The target host is not reachable.
		return NotReachable;
	}

    NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = ReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = ReachableViaWWAN;
	}
    
	return returnValue;
}


- (BOOL)connectionRequired
{
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}

    return NO;
}


- (NetworkStatus)currentReachabilityStatus
{
	NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	NetworkStatus returnValue = NotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
		if (_alwaysReturnLocalWiFiStatus)
		{
			returnValue = [self localWiFiStatusForFlags:flags];
		}
		else
		{
			returnValue = [self networkStatusForFlags:flags];
		}
	}
    
	return returnValue;
}

/* Static version for checks without subscribing */
+ (NetworkStatus)currentReachabilityStatus
{
    _alwaysReachability = [VCLReachability createOrReturnReachabilityWithReachability:_alwaysReachability forReachabilityConnection:[VCLReachability reachabilityAlways]];
    
	NSAssert(_alwaysReachability->_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	NetworkStatus returnValue = NotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_alwaysReachability->_reachabilityRef, &flags))
	{
		if (_alwaysReachability->_alwaysReturnLocalWiFiStatus)
		{
			returnValue = [_alwaysReachability localWiFiStatusForFlags:flags];
		}
		else
		{
			returnValue = [_alwaysReachability networkStatusForFlags:flags];
		}
	}
    
	return returnValue;
}

#pragma mark - Publish Methods

+ (void)postNotificationTo:(NSString*)postNotificationName withReachability:(VCLReachability*)reachability {
    [[NSNotificationCenter defaultCenter] postNotificationName: postNotificationName object: reachability];
}

#pragma mark - Subscription Methods

/*
 Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
 */
+ (void)subscribeToReachabilityNotificationsWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    
    // If an instance of _alwaysReachability isn't created yet create one
    _alwaysReachability = [VCLReachability createOrReturnReachabilityWithReachability:_alwaysReachability forReachabilityConnection:[VCLReachability reachabilityAlways]];

    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    // send the first notification
    [VCLReachability postNotificationTo:kReachabilityChangedNotification withReachability:_alwaysReachability];
}


/*
 Subscribe to changes in WiFI VLReachability
 */
+ (void)unsubscribeToReachabilityNotificationsWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    /*
     Unobserve the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:kReachabilityChangedNotification object:nil];
}

+ (void)subscribeToReachabilityForWifiWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    
    // If an instance of _wifiReachability isn't created yet create one
    _wifiReachability = [VCLReachability createOrReturnReachabilityWithReachability:_wifiReachability forReachabilityConnection:[VCLReachability reachabilityForLocalWiFi]];
    
    // Subscribe to change in network connectivity for wifi instance of reachability only
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(wifiReachabilityChanged:) name:kWifiReachabilityChangedNotification object:_wifiReachability];
    
    // send the first notification
    [VCLReachability postNotificationTo:kWifiReachabilityChangedNotification withReachability:_wifiReachability];
}

/*
 Unsubscribe to changes in WiFI VLReachability
 */
+ (void)unsubscribeToReachabilityForWifiWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:kWifiReachabilityChangedNotification object:_wifiReachability];
}

/*
 Subscribe to changes in Host Name VLReachability
 */
+ (void)subscribeToReachabilityForHostNameWithName:(NSString *)hostName delegate:(id<VCLReachabilitySubscriber>) delegate {
    // If an instance of _hostNames isn't created yet create one
    if (!_hostNames) {
        _hostNames = [NSMutableDictionary new];
    }
    
    // If an instance of hostName reachability isn't created yet create one
    if(![_hostNames objectForKey:hostName]) {
        VCLReachability* newReachability;
        [_hostNames setObject:[VCLReachability createOrReturnReachabilityWithReachability:newReachability forReachabilityConnection:[VCLReachability reachabilityWithHostName:hostName]] forKey:hostName];
    }
    
    // Subscribe to change in network connectivity for wifi instance of reachability only
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(hostNameReachabilityChanged:) name:kHostNameReachabilityChangedNotification object:[_hostNames objectForKey:hostName]];
    
    // send the first notification
    [VCLReachability postNotificationTo:kHostNameReachabilityChangedNotification withReachability:[_hostNames objectForKey:hostName]];
}

/*
 Unsubscribe to changes in Host Name VLReachability
 */
+ (void)unsubscribeToReachabilityForHostNameWithName:(NSString *)hostName delegate:(id<VCLReachabilitySubscriber>) delegate {
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:kHostNameReachabilityChangedNotification object:[_hostNames objectForKey:hostName]];
}

/*
 Subscribe to changes in Internet VLReachability
 */
+ (void)subscribeToReachabilityForInternetConnectionWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    // If an instance of _internetReachability isn't created yet create one
    _internetReachability = [VCLReachability createOrReturnReachabilityWithReachability:_internetReachability forReachabilityConnection:[VCLReachability reachabilityForInternetConnection]];
    
    // Subscribe to change in network connectivity for internet instance of reachability only
    [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(internetReachabilityChanged:) name:kInternetReachabilityChangedNotification object:_internetReachability];
    
    // send the first notification
    [VCLReachability postNotificationTo:kInternetReachabilityChangedNotification withReachability:_internetReachability];
}

/*
 Unsubscribe to changes in Internet VLReachability
 */
+ (void)unsubscribeToReachabilityForInternetConnectionWithDelegate:(id<VCLReachabilitySubscriber>) delegate {
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:kInternetReachabilityChangedNotification object:_internetReachability];
}

#pragma mark - Setters

+ (void)setHostNamesWithReachability:(VCLReachability*)reachability forHostName:(NSString*)hostName {
    [_hostNames setObject:reachability forKey:hostName];
}

+ (VCLReachability*)createOrReturnReachabilityWithReachability:(VCLReachability*)reachability forReachabilityConnection:(VCLReachability*)reachabilityConnectionType {
    if (!reachability) {
        reachability = reachabilityConnectionType;
        [reachability startNotifier];
    }
    return reachability;
}

#pragma mark - Getters
- (NSString*)notificationType {
    return self->_notificationType;
}
+ (VCLReachability*)internetReachability{
    return _internetReachability;
}
+ (VCLReachability*)wifiReachability{
    return _wifiReachability;
}
+ (NSMutableDictionary*)hostNames{
    return _hostNames;
}
+ (VCLReachability*)hostNameWithKey:(NSString*)hostName{
    return [_hostNames valueForKey:hostName];
}


@end
