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
#import "CFTEnum.h"
@class CFTCard;
@class CFTCharge;

@protocol CFTReaderDelegate <NSObject>

@required

/*
 * Required protocol method that gets called when the hardware
 * reader has received a complete swipe. Returns a CFTCard object
 * with success and a NSError on failure.
 *
 * Added in 1.0
 */
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error;


/*
 * Required protocol method that gets called when a transaction has completed.
 * Returns a CFTCharge on success and a NSError on failure.
 *
 * Added in 2.0
 */
- (void)transactionResult:(CFTCharge *)charge withError:(NSError *)error;

@optional

/*
 * Optional protocol method that passes a suggested message to be 
 * displayed to the user during an EMV transaction. Messages are generated
 * on the reader based on its current state.
 *
 * Added in 2.0
 */
- (void)emvMessage:(CFTEMVMessage)message;

/*
 * Optional protocol method that gets called after the hardware
 * reader is physically attached.
 *
 * Added in 1.0
 */
- (void)readerIsAttached;

/*
 * Optional protocol method that gets called after a hardware
 * reader begins the connection process.
 *
 * Added in 2.0
 */
- (void)readerIsConnecting;

/*
 * Optional protocol method that gets called after an attempt is made
 * to connect with the hardware reader. If isConnected is FALSE then
 * the NSError object will contain the description.
 *
 * Added in 1.0
 */
- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error;

/*
 * Optional protocol method that gets called when a swipe is detected.
 *
 * Added in 2.0
 */
- (void)readerSwipeDetected;

/*
 * Optional protocol method that gets called after the hardware reader
 * is disconnected and physically detached.
 *
 * Added in 1.0
 */
- (void)readerIsDisconnected;

/*
 * Optional protocol method that gets called after the user cancels
 * a swipe.
 *
 * Added in 1.0
 */
- (void)readerSwipeDidCancel;

/*
 * Optional protocol method to notify you of low batter status in readers
 * that have a battery.
 *
 * Added in 2.0
 */
- (void)readerBatteryLow;

/*
 * Optional protocol method that gets called if all reader types have attempted
 * to connect and no reader was detected.
 *
 * Added in 2.0
 */
- (void)readerNotDetected;

// ******************** DEPRECATED ********************

/*
 * Optional protocol method that gets called after the serial number
 * of the hardware reader has been retrieved.
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0.
 */
- (void)readerSerialNumber:(NSString *)serialNumber __deprecated;

/*
 * Optional protocol method that gets called in a non credit card is
 * swiped. The raw data from swipe is passed without any processing.
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0.
 */
- (void)readerGenericResponse:(NSString *)cardData __deprecated;

@end

@interface CFTReader : NSObject

@property (nonatomic, weak) id<CFTReaderDelegate> delegate;

/*
 * Initialization method with optional parameter to set the type of
 * reader being used for faster connections. Defaults to auto connect.
 * Pass 0 to specify auto connect.
 *
 * Added in 2.0
 */
- (id)initWithReader:(NSUInteger)reader;

/*
 * Method that returns the last connected reader type. This value
 * can be saved and passed back into initWithReader to shorten the
 * connection time.
 *
 * Added in 2.0
 */
- (NSUInteger)readerType;

/*
 * Optional method to set whether reader times out while waiting
 * for a swipe after 20 seconds. Default is YES.
 *
 * Added in 2.0
 */
- (void)swipeHasTimeout:(BOOL)hasTimeout;

/*
 * Set the hardware reader to begin waiting to receive a swipe or
 * starts an EMV transaction. Does NOT return a card object, the charge
 * is made immediately.
 *
 * Returns an error if an invalid charge dictionary is passed or amount is
 * not passed.
 *
 * chargeDictionary parameters:
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of ISO 3166-1 numeric currency code,
 *                 ** 840 (USD) is the default and only currently supported currency **
 *      merchant_id - Optional - NSString of Braintree submerchant ID
 *                    ** Not currently supported for EMV, use for mag stripe only **
 *      service_fee - Optional - NSDecimalNumber containing the fee to charge
 *                    ** Not currently supported for EMV, use for mag stripe only **
 *
 * Added in 2.0
 */
- (NSError *)beginTransactionWithAmount:(NSDecimalNumber *)amount
                    andChargeDictionary:(NSDictionary *)chargeDictionary;

/*
 * Set the hardware reader to begin waiting to receive a swipe.
 * Legacy method, supports mag stripe transactions only.
 * Returns a card object that can be charged later.
 *
 * Updated in 2.0
 */
- (void)beginSwipe;

/*
 * Manually cancel the swipe process before the timeout duration has
 * been reached or cancels an EMV transaction.
 */
- (void)cancelTransaction;

// ******************** DEPRECATED ********************

/*
 * Optional method to set the duration before a swipe command will
 * timeout. Setting the duration to 0 will cause the swipe to never
 * timeout.
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0, please use swipeHasTimeout instead.
 */
- (void)swipeTimeoutDuration:(NSInteger)duration __deprecated;

/*
 * Manually cancel the swipe process before the timeout duration has
 * been reached.
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0, please use cancelTransaction instead.
 */
- (void)cancelSwipeWithMessage:(NSString *)message __deprecated;

/*
 * Communicate with the hardware reader and retrieve the serial number.
 * The hardware reader must not be performing any other functions.
 * Returns YES if command is successfully started, NO otherwise.
 *
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 2.0, please use cancelSwipe instead.
 */
- (BOOL)retrieveSerialNumber __deprecated;

@end
