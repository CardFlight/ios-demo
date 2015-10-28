/*
 *****************************************************************
 * CFTAttacheReader.h
 *
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <Foundation/Foundation.h>
@class CFTCard;

@protocol CFTAttacheReaderDelegate <NSObject>

@required

/*!
 * @discussion Required protocol method that gets called when the hardware
 * reader has received a complete swipe. Returns a CFTCard object
 * with success and a NSError on failure.
 */
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error;

@optional

/*!
 * @discussion Optional protocol method that gets called after the hardware
 * reader is physically attached.
 */
- (void)readerIsAttached;

/*!
 * @discussion Optional protocol method that gets called after a hardware
 * reader begins the connection process.
 */
- (void)readerIsConnecting;

/*!
 * @discussion Optional protocol method that gets called after an attempt is made
 * to connect with the hardware reader. If isConnected is FALSE then
 * the NSError object will contain the description.
 */
- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error;

/*!
 * @discussion Optional protocol method that gets called in a non credit card is
 * swiped. The raw data from swipe is passed without any processing.
 */
- (void)readerGenericResponse:(NSString *)cardData;

/*!
 * @discussion Optional protocol method that gets called after the hardware reader
 * is disconnected and physically detached.
 */
- (void)readerIsDisconnected;

/*!
 * @discussion Optional protocol method that gets called after the serial number
 * of the hardware reader has been retrieved.
 */
- (void)readerSerialNumber:(NSString *)serialNumber;

/*!
 * @discussion Optional protocol method that gets called after the user cancels
 * a swipe.
 */
- (void)readerSwipeDidCancel;

@end

@interface CFTAttacheReader : NSObject

@property (nonatomic, weak) id<CFTAttacheReaderDelegate> delegate;

/*!
 * @discussion Create a new CFTReader and have it attempt to connect to the
 * hardware reader immediately.
 */
- (id)initAndConnect;

@end
