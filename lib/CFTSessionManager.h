/*
 *****************************************************************
 * CardFlight.h
 *
 * A CardFlight singleton is created to maintain session-wide
 * settings and information.
 *
 * All additional functionality is supplied by the individual class
 * related to the function that you want to perform. Only the
 * classes required need to be included in a file.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */
#import <Foundation/Foundation.h>

@interface CFTSessionManager : NSObject

/*
 * Accessor for the CardFlight singleton
 *
 * Added in 1.7
 */
+ (CFTSessionManager *)sharedInstance;

/*
 * Convenience method to return the current version number of the SDK
 *
 * Added in 1.0
 */
- (NSString *)SDKVersion;

/*
 * Convenience method to return the current API token
 *
 * Added in 2.0
 */
- (NSString *)apiToken;

/*
 * Convenience method to return the current Account token
 *
 * Added in 2.0
 */
- (NSString *)accountToken;

/*
 * Sets the API account token for the entire session. This only
 * needs to be called once, most likely in applicationDidFinishLaunching
 */
- (void)setApiToken:(NSString *)cardFlightApiToken
       accountToken:(NSString *)cardFlightAccountToken;

/*
 * Pass YES to enable developer logging mode to the console.
 * This should always be set to NO for release
 */
- (void)setLogging:(BOOL)logging;

// ******************** DEPRECATED ********************

/*
 * Convenience method to return the current API token
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0, please use apiToken instead.
 */
- (NSString *)getApiToken __deprecated;

/*
 * Convenience method to return the current Account token
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0, please use accountToken instead.
 */
- (NSString *)getAccountToken __deprecated;

@end
