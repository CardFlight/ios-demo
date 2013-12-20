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

@interface CardFlight : NSObject

/**
 * Accessor for the CardFlight singleton
 */
+ (CardFlight *)sharedInstance;

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

@end