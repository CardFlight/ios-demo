/*
 *****************************************************************
 * CFTReader.h
 *
 * Class to manage the hardware reader. Contains a protocol that
 * must be implemented by a delegate in order to process
 * responses from the hardware reader.
 *
 * An instance of CFTCard is returned after a successful swipe.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import "CFTBaseReader.h"
@class CFTCard;

@interface CFTReader : CFTBaseReader

/**
 * Optional method to set the duration before a swipe command will
 * timeout. Setting the duration to 0 will cause the swipe to never
 * timeout.
 */
- (void)swipeTimeoutDuration:(NSInteger)duration;

/**
 * Set the hardware reader to begin waiting to receive a swipe.
 * message sets an optional display message while the reader is waiting
 * to receive data.
 */
- (void)beginSwipeWithMessage:(NSString *)message;

/**
 * Manually cancel the swipe process before the timeout duration has
 * been reached.
 */
- (void)cancelSwipeWithMessage:(NSString *)message;

/**
 * Communicate with the hardware reader and retrieve the serial number.
 * The hardware reader must not be performing any other functions.
 * Returns YES if command is successfully started, NO otherwise.
 */
- (BOOL)retrieveSerialNumber;

// ******************** DEPRECATED ********************

/**
 * Manually attempt the connection process with the hardware reader.
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (void)connect __attribute__((deprecated));

/**
 * Manually attempt the disconnect process with the hardware reader.
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (void)disconnect __attribute__((deprecated));

@end
