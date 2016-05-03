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
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CFTEnum.h"
@class CFTCard;
@class CFTCharge;

@protocol CFTReaderDelegate <NSObject>

@optional

// ****************  REQUIRED CALLBACKS FOR EMV  ****************

/*!
 * @brief Callback after completion of EMV transacion
 * @param charge CFTCharge object containing the completed charge
 * @param signature BOOL indicating if a signature CVM is required
 * @param error Contains a NSError if the charge did not complete
 * @discussion This callback is triggered after an EMV transaction completes.
 * It contains a CFTCharge on success (either approved or declined) and an
 * NSError if the charge fails.
 * Required for EMV transactions.
 * Updated in 3.0
 */
- (void)emvTransactionResult:(CFTCharge *)charge
           requiresSignature:(BOOL)signature
                   withError:(NSError *)error;

/*!
 * @brief Callback after application selection is requested during an EMV transaction
 * @param applicationArray NSArray of application names, sorted by priority
 * @discussion This callback is triggered if the ICC card contains more than 1
 * supported AID. An array is passed for selection by the customer. Call
 * emvSelectApplication: to select an AID.
 * Required for EMV transactions.
 * Added in 3.0
 */
- (void)emvApplicationSelection:(NSArray *)applicationArray;

/*!
 * @brief Callback to display EMV terminal messages
 * @param message CFTEMVMessage enumeration type to display
 * @discussion This callback is triggered whenever the terminal requests
 * a message be displayed to the user. These messages should be displayed
 * whenever possible.
 * Required for EMV transactions.
 * Added in 2.0
 */
- (void)emvMessage:(CFTEMVMessage)message;

/*!
 * @brief Callback that passes credit card information for verification
 * @param cardDictionary NSDictionary contain last4 (NSString) and cardType (boxed NSNumber)
 * for display to the user
 * @discussion This callback is triggered when card info from a credit card dipped
 * during an EMV transaction is read. Display to the user and call emvProcessTransaction:
 * to accept or reject this card for processing.
 * Required for EMV transactions.
 * Added in 3.0
 */
- (void)emvCardResponse:(NSDictionary *)cardDictionary;

/*!
 * @brief Callback if an error is triggerd during an EMV transaction
 * @param error NSError passed from the terminal
 * @discussion This callback is triggered if a non-fatal error occurs
 * during an EMV transaction.
 * Required for EMV transactions.
 * Added in 2.0
 */
- (void)emvErrorResponse:(NSError *)error;

/*!
 * @brief Callback when the amount has not been set for an EMV transaction
 @ @discussion This callback is triggered if the amount has not been set for
 * an EMV transaction. Use emvTransactionAmount: to set the amount.
 * Required for EMV transactions.
 * Added in 2.0
 */
- (void)emvAmountRequested;

/*!
 * @brief Callback when the battery in the terminal is low
 * @discussion This callback is triggered if the battery in the terminal
 * is low. It may still be possible to run a transaction, however the battery
 * should be charged as soon as possible.
 * Required for EMV transactions.
 * Added in 2.0
 */
- (void)readerBatteryLow;

/*!
 * @brief Callback when a card is inserted into the reader
 * @discussion This callback is triggered when a card is inserted into the reader
 * and the reader is actively processing an EMV transactions.
 * Required for EMV transaction.
 * Added in 3.0
 */
- (void)emvCardDipped;

/*!
 * @brief Callback when the card is removed from the reader
 * @discussion This callback is triggered whenever the dipped card is removed
 * from the reader. Useful for ensuring the card is removed at the end of an
 * EMV transaction, but will be called anytime a card is removed.
 * Required for EMV transactions.
 * Added in 3.0
 */
- (void)emvCardRemoved;

// ****************  END OF REQUIRED CALLBACKS FOR EMV  ****************

/*!
 * @brief Callback for when a swiped card is generated
 * @param card CFTCard that was generated from the swipe
 * @param error NSError if a card could not be generated
 * @discussion This callback is triggered after a swipe. If a card
 * can be successfully generated the card param is populated, else
 * the error is populated with the resulting error.
 * Updated in 3.0
 */
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error;

/*!
 * @brief Callback for when the reader is attached to the device
 * @discussion This callback is triggered when a reader is detected
 * by the SDK, but the reader is not ready to recieve commands yet.
 * Added in 1.0
 */
- (void)readerIsAttached;

/*!
 * @brief Callback for when the SDK begins the connecting process
 * @discussion This callback is triggered when the SDK begins the connecting
 * process with the reader.
 * Added in 2.0
 */
- (void)readerIsConnecting;

/*!
 * @brief Callback for when the SDK completes the connection process
 * @param isConnected BOOL indicating if the reader is connected
 * @param error NSError populated if the process was not successful
 * @discussion This callback is triggered when the connection process
 * is complete. An error is returned if the process did not complete
 * successfully.
 * Added in 1.0
 */
- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error;

/*!
 * @brief Callback for when a swipe is detected by the reader
 * @discussion This callback is triggered when a swipe is detected but
 * before it's been processed.
 * Added in 2.0
 */
- (void)readerSwipeDetected;

/*!
 * @brief Callback for when the reader is disconnected
 * @discussion This callback is triggered when the reader is disconnected
 * from the device.
 * Added in 1.0
 */
- (void)readerIsDisconnected;

/*!
 * @brief Callback for when a swipe has been cancelled
 * @discussion This callback is triggered after a swipe has been cancelled.
 * Added in 1.0
 */
- (void)readerSwipeDidCancel;

/*!
 * @brief Callback for when no reader was detected
 * @discussion This callback is triggered when a connection attempt has been
 * made but no reader was detected.
 * Added in 2.0
 */
- (void)readerNotDetected;

/*!
 * @brief For internal use only
 */
- (void)callback:(NSDictionary *)parameters;

@end

@interface CFTReader : NSObject

@property (nonatomic, weak) id<CFTReaderDelegate> delegate;

/*!
 * @brief Initilizer with optional reader type
 * @param reader NSUInteger to specify reader type. 0 for auto detect.
 * @discussion Initialization method with optional parameter to set the type of
 * reader being used for faster connections. Defaults to auto connect.
 * Added in 2.0
 */
- (id)initWithReader:(NSUInteger)reader;

/*!
 * @brief Get the reader type of the currently connected reader
 * @return NSUInteger representing the current reader type
 * @discussion Method that returns the last connected reader type. This value
 * can be saved and passed back into initWithReader to shorten the
 * connection time.
 * Added in 2.0
 */
- (NSUInteger)readerType;

/*!
 * @brief Set the reader to begin waiting for a card swipe
 * @discussion Set the hardware reader to begin waiting to receive a swipe.
 * Legacy method, supports mag stripe transactions only.
 * Updated in 3.0
 */
- (void)beginSwipe;

/*!
 * @brief Set the reader to auto timeout after 20 seconds
 * @param hasTimeout BOOL to set timeout on or off
 * @discussion Optional method to set whether reader times out while waiting
 * for a swipe after 20 seconds. Default is YES. Note: This method has
 * no effect during an EMV transaction.
 * Added in 2.0
 */
- (void)swipeHasTimeout:(BOOL)hasTimeout;

/*!
 * @brief Manually cancel a swipe transaction
 * @discussion Manually cancel the swipe process before the timeout duration has
 * been reached or cancels an EMV transaction.
 */
- (void)cancelTransaction;

/*!
 * @brief Get the current state of the reader
 * @return CFTReaderState enumeration of the current state
 * @discussion Returns the current state of the reader as a
 * CFTReaderState enumeration.
 * Added in 3.0
 */
- (CFTReaderState)readerState;


/*!
 * @brief Safely stop reader
 * @discussion Stop reader action in safe manner and clear all delegates.
 * Added in 3.1
 */
- (void)destroy;

// **************** EMV RELATED METHODS ****************

/*!
 * @brief Start an EMV transaction
 * @param amount NSDecimalNumber of the amount to charge
 * @param chargeDictionary NSDictionary of charge data for the transaction
 * @return NSError if the transaction was unable to start
 * @discussion Begin an EMV transaction with the requested amount. Does not return
 * a card object. Processes the complete transaction and returns an
 * emvTransactionResult.
 * Returns an errror if unable to start the transaction.
 *
 * chargeDictionary parameters:
 *      description - Optional - NSString of charge description
 *      metadata - Optional - NSDictionary of extra transaction information
 *
 * Added in 3.0
 */
- (NSError *)beginEMVTransactionWithAmount:(NSDecimalNumber *)amount
                       andChargeDictionary:(NSDictionary *)chargeDictionary;

/*!
 * @brief Set the EMV transaction amount
 * @param amount NSDecimalNumber of the amount to charge
 * @discussion Set the transaction amount for an EMV transaction if not previously set.
 * This is done in response to emvAmountRequested callback.
 * Added in 2.0
 */
- (void)emvTransactionAmount:(NSDecimalNumber *)amount;

/*!
 * @brief Select the application in a multy AID transaction
 * @param application Index of the application selected
 * @discussion Set the application to be used for an EMV transaction. 
 * Used in conjunction with emvApplicationSelection protocol method.
 * Added in 3.0
 */
- (void)emvSelectApplication:(NSInteger)application;

/*!
 * @brief Confirm processing of EMV transaction
 * @param process BOOL to confirm the card info
 * @discussion After recieving the card information for an EMV transaction,
 * send a confirmation to continue processing the transaction.
 * Added in 3.0
 */
- (void)emvProcessTransaction:(BOOL)process;

/*!
 * @brief Attach a signature to an EMV transaction
 * @param signatureData NSData of a base64 encoded image
 * @param success Success block called if transaction is uploaded
 * @param failure Failure block called with NSError is transaction fails to upload
 * @discussion If the transaction requires a signatue as indicated in
 * emvTransactionResult this method is used to attach the signature.
 * Updated in 3.2
 */
- (void)emvTransactionSignature:(NSData *)signatureData
                        success:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure;

/*!
 * @brief Get default text for an EMV message category
 * @param message CFTEMVMessage to get the default text for
 * @return English language string containing the default text
 * @discussion CFTEMVMessages are enumerations of a category of message types.
 * This convienence method returns default text that can be used if you do not
 * wish to supply your own.
 * Added in 3.0
 */
- (NSString *)defaultMessageForCFTEMVMessage:(CFTEMVMessage)message;

@end
