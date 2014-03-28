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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CFTCard;

@protocol readerDelegate <NSObject>

@required

/**
 * Required protocol method that gets called when the hardware
 * reader has received a complete swipe. Returns a CFTCard object
 * with success and a NSError on failure.
 */
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error;

@optional

/**
 * Optional protocol method that gets called after the hardware
 * reader is physically attached.
 */
- (void)readerIsAttached;

/**
 * Optional protocol method that gets called after a hardware
 * reader begins the connection process.
 */
- (void)readerIsConnecting;

/**
 * Optional protocol method that gets called after an attempt is made
 * to connect with the hardware reader. If isConnected is FALSE then
 * the NSError object will contain the description.
 */
- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error;

/**
 * Optional protocol method that gets called in a non credit card is
 * swiped. The raw data from swipe is passed without any processing.
 */
- (void)readerGenericResponse:(NSString *)cardData;

/**
 * Optional protocol method that gets called after the hardware reader
 * is disconnected and physically detached.
 */
- (void)readerIsDisconnected;

/**
 * Optional protocol method that gets called after the serial number
 * of the hardware reader has been retrieved.
 */
- (void)readerSerialNumber:(NSString *)serialNumber;

/**
 * Optional protocol method that gets called after the user cancels
 * a swipe.
 */
- (void)readerSwipeDidCancel;

@end

@interface CFTReader : NSObject

@property (nonatomic, weak) id<readerDelegate> delegate;

/**
 * Create a new CFTReader and have it attempt to connect to the 
 * hardware reader immediately.
 */
- (id)initAndConnect;

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
- (void)connect;

/**
 * Manually attempt the disconnect process with the hardware reader.
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (void)disconnect;

@end
