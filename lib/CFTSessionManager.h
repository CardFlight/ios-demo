/*
 *****************************************************************
 * CFTSessionManager.h
 *
 * A CardFlight singleton is created to maintain session-wide
 * settings and information.
 *
 * All additional functionality is supplied by the individual class
 * related to the function that you want to perform. Only the
 * classes required need to be included in a file.
 *
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */
#import <Foundation/Foundation.h>

@protocol CFTSessionProtocol <NSObject>

@optional

/*!
 * @brief Capture logging messages
 * @param output NSString of log message
 * @discussion Optional callback to reroute logging messages to a
 * file instead of to the console.
 * Added in 2.0.5
 */
- (void)logOutput:(NSString *)output;

@end

@interface CFTSessionManager : NSObject
@property (nonatomic, readonly) BOOL isEMVMerchantAccount;
@property (nonatomic, weak) id <CFTSessionProtocol> delegate;

/*!
 * @brief Accessor for the session manager singleton
 * @discussion Access the session manager singleton
 * Added in 1.7
 */
+ (CFTSessionManager *)sharedInstance;

/*!
 * @brief Get current SDK version
 * @return NSString of current SDK version
 * @discussion Convenience method to return the current version number of the SDK.
 * Added in 1.0
 */
- (NSString *)SDKVersion;

/*!
 * @brief Get the current API token
 * @return NSString of current API token
 * @discussion Convenience method to return the current API token.
 * Added in 2.0
 */
- (NSString *)apiToken;

/*!
 * @brief Get the current account token
 * @return NSString of current account token
 * @discussion Convenience method to return the current Account token.
 * Added in 2.0
 */
- (NSString *)accountToken;

/*!
 * @brief Set the API and account tokens for the session
 * @param cardFlightApiToken NSString of the API token
 * @param cardFlightAccountToken NSString of the account token
 * @param completed Block called when the session manager is ready to process transactions
 * @discussion Sets the API account token for the entire session. This only
 * needs to be called once, most likely in applicationDidFinishLaunching, but
 * it can be called multiple times to use different credentials.
 * Added in 3.2
 */
- (void)setApiToken:(NSString *)cardFlightApiToken
       accountToken:(NSString *)cardFlightAccountToken
          completed:(void(^)(BOOL emvReady))completed;

/*!
 * @brief Set logging mode of the SDK
 * @param logging BOOL to turn on or off logging mode
 * @discussion Pass YES to enable developer logging mode to the console.
 * Added in 1.0
 */
- (void)setLogging:(BOOL)logging;

// ******************** DEPRECATED ********************

/*!
 * @brief Set the API and account tokens for the session
 * @param cardFlightApiToken NSString of the API token
 * @param cardFlightAccountToken NSString of the account token
 * @discussion Sets the API account token for the entire session. This only
 * needs to be called once, most likely in applicationDidFinishLaunching, but
 * it can be called multiple times to use different credentials.
 *
 * THIS WILL BE REMOVED IN A FUTURE RELEASE
 * Deprecated in 3.2
 */
- (void)setApiToken:(NSString *)cardFlightApiToken
       accountToken:(NSString *)cardFlightAccountToken __deprecated;

@end
