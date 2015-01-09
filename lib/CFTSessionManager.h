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

/**
 * Accessor for the CardFlight singleton
 */
+ (CFTSessionManager *)sharedInstance;

/**
 * Convenience method to return the current version number of the SDK
 */
- (NSString *)SDKVersion;

/**
 * Convenience method to return the current API token
 */
- (NSString *)getApiToken;

/**
 * Convenience method to return the current Account token
 */
- (NSString *)getAccountToken;

/**
 * Sets the API account token for the entire session. This only
 * needs to be called once, most likely in applicationDidFinishLaunching
 */
- (void)setApiToken:(NSString *)cardFlightApiToken
       accountToken:(NSString *)cardFlightAccountToken;

/**
 * Pass YES to enable developer logging mode to the console.
 * This should always be set to NO for release
 */
- (void)setLogging:(BOOL)logging;

// ******************** DEPRECATED ********************

/**
 * Pass YES to this method to enable lightning connector mode
 * for the attache reader. The default is NO
 */
- (void)setAttacheReader:(BOOL)isAttache __attribute__((deprecated));

@end