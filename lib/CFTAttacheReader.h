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
- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error __deprecated;

@optional

/*!
 * @discussion Optional protocol method that gets called after the hardware
 * reader is physically attached.
 */
- (void)readerIsAttached __deprecated;

/*!
 * @discussion Optional protocol method that gets called after a hardware
 * reader begins the connection process.
 */
- (void)readerIsConnecting __deprecated;

/*!
 * @discussion Optional protocol method that gets called after an attempt is made
 * to connect with the hardware reader. If isConnected is FALSE then
 * the NSError object will contain the description.
 */
- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error __deprecated;

/*!
 * @discussion Optional protocol method that gets called in a non credit card is
 * swiped. The raw data from swipe is passed without any processing.
 */
- (void)readerGenericResponse:(NSString *)cardData __deprecated;

/*!
 * @discussion Optional protocol method that gets called after the hardware reader
 * is disconnected and physically detached.
 */
- (void)readerIsDisconnected __deprecated;

/*!
 * @discussion Optional protocol method that gets called after the serial number
 * of the hardware reader has been retrieved.
 */
- (void)readerSerialNumber:(NSString *)serialNumber __deprecated;

/*!
 * @discussion Optional protocol method that gets called after the user cancels
 * a swipe.
 */
- (void)readerSwipeDidCancel __deprecated;

@end

__deprecated_msg("Attache reader support is deprecated, please contact support@cardflight.com for alternatives")
/*
 * THIS CLASS WILL BE REMOVED IN A LATER RELEASE
 * Deprecated in 3.2.1
 */
@interface CFTAttacheReader : NSObject

@property (nonatomic, weak) id<CFTAttacheReaderDelegate> delegate;

/*!
 * @discussion Create a new CFTReader and have it attempt to connect to the
 * hardware reader immediately.
 */
- (id)initAndConnect __deprecated;

@end
