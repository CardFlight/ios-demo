/*
 *****************************************************************
 * CFTEnum.h
 *
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

typedef NS_ENUM(NSUInteger, CFTEMVMessage) {
    EMVMessage_UNKNOWN,
    EMVMessage_AMOUNT_OK,
    EMVMessage_APPLICATION_BLOCKED,
    EMVMessage_APPROVED,
    EMVMessage_CALL_BANK,
    EMVMessage_CAPK_FAIL,
    EMVMessage_CARD_BLOCKED,
    EMVMessage_CARD_ERROR,
    EMVMessage_CARD_NOT_SUPPORTED,
    EMVMessage_CLEAR_DISPLAY,
    EMVMEssage_CONDITIONS_NOT_SATISFIED,
    EMVMessage_DECLINED,
    EMVMessage_DEVICE_ERROR,
    EMVMessage_DIP_OR_SWIPE,
    EMVMessage_ENTER_AMOUNT,
    EMVMessage_ENTER_PIN,
    EMVMessage_ICC_CARD_REMOVED,
    EMVMessage_INCORRECT_PIN,
    EMVMessage_INSERT_CARD,
    EMVMessage_INVALID_ICC_DATA,
    EMVMessage_MISSING_DATA,
    EMVMessage_NO_EMV_APP,
    EMVMessage_NOT_ACCEPTED,
    EMVMessage_NOT_ICC,
    EMVMessage_ONLINE_REQUIRED,
    EMVMessage_PIN_OK,
    EMVMessage_PLEASE_WAIT,
    EMVMessage_PRESENT_ONLY_ONE_CARD,
    EMVMessage_PROCESSING,
    EMVMessage_PROCESSING_ERROR,
    EMVMessage_REMOVE_CARD,
    EMVMessage_SET_AMOUNT_CANCEL_OR_TIMEOUT,
    EMVMessage_TERMINATED,
    EMVMessage_TRANSACTION_CANCELLED,
    EMVMessage_TRY_AGAIN,
    EMVMessage_TRY_DIP_AGAIN,
    EMVMessage_TRY_SWIPE_AGAIN,
    EMVMessage_USE_CHIP_READER,
    EMVMessage_USE_MAG_READER,
    EMVMessage_WELCOME,
    EMVMessage_NO_MESSAGE
};

typedef NS_ENUM (NSUInteger, CFTCardType) {
    CFTCardTypeVisa,
    CFTCardTypeMasterCard,
    CFTCardTypeAmex,
    CFTCardTypeDiscover,
    CFTCardTypeJCB,
    CFTCardTypeDinersClub,
    CFTCardTypeUnknown
};

typedef NS_ENUM (NSUInteger, CFTReaderState) {
    ReaderState_UNKNOWN = 0,
    ReaderState_WAITING_FOR_CONNECT,
    ReaderState_ATTACHED,
    ReaderState_CONNECTED,
    ReaderState_WAITING_FOR_DIP,
    ReaderState_WAITING_FOR_SWIPE,
    ReaderState_SWIPE_DETECTED,
    ReaderState_CARD_INSERTED,
    ReaderState_REMOVE_CARD,
    ReaderState_DISCONNECTED,
    ReaderState_NOT_FOUND
};
