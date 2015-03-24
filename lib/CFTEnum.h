//
//  CFTEnum.h
//  CardFlightLibrary
//
//  Created by Paul Tower on 2/25/15.
//  Copyright (c) 2015 CardFlight Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, CFTEMVMessage) {
    EMVMessage_UNKNOWN,
    EMVMessage_AMOUNT_OK,
    EMVMessage_APPROVED,
    EMVMessage_CALL_BANK,
    EMVMessage_CARD_ERROR,
    EMVMessage_CLEAR_DISPLAY,
    EMVMessage_DECLINED,
    EMVMessage_ENTER_AMOUNT,
    EMVMessage_ENTER_PIN,
    EMVMessage_INCORRECT_PIN,
    EMVMessage_INSERT_CARD,
    EMVMessage_NOT_ACCEPTED,
    EMVMessage_ONLINE_REQUIRED,
    EMVMessage_PIN_OK,
    EMVMessage_PLEASE_WAIT,
    EMVMessage_PRESENT_ONLY_ONE_CARD,
    EMVMessage_PROCESSING,
    EMVMessage_PROCESSING_ERROR,
    EMVMessage_REMOVE_CARD,
    EMVMessage_TRANSACTION_CANCELLED,
    EMVMessage_TRY_AGAIN,
    EMVMessage_TRY_DIP_AGAIN,
    EMVMessage_TRY_SWIPE_AGAIN,
    EMVMessage_USE_CHIP_READER,
    EMVMessage_USE_MAG_READER,
    EMVMessage_WELCOME
};

typedef NS_ENUM(NSUInteger, CFTCardProcessor) {
    UNKNOWN,
    VISA,
    MASTERCARD,
    AMEX,
    DINERS,
    DISCOVER,
    JCB
};
