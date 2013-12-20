/*
 *****************************************************************
 * CFTCard.h
 *
 * Class to handle all functions associated with a particular
 * credit card. Is returned after a successful swipe or after
 * calling generateCard from the custom manual entry UIView.
 * 
 * Charges are called on the specific card they are to be applied
 * to. A CFTCharge object is returned.
 *
 * Contains convenience validation methods that can optionally
 * be called for client-side validation of card formats during
 * manual entry.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import "CFTAPIResource.h"
@class CFTCharge;

typedef enum CFCardType {
    UNKNOWN,
    VISA,
    MASTERCARD,
    AMEX,
    DINERS,
    DISCOVER,
    JCB
} CFCardType;

@interface CFTCard : CFTAPIResource

@property (nonatomic) NSString *last4;
@property (nonatomic) NSInteger expirationMonth;
@property (nonatomic) NSInteger expirationYear;
@property (nonatomic) CFCardType cardType;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *encryptedCardNumber;
@property (nonatomic) NSString *cardToken;

/**
 * Convenience method to check that the credit card number is formatted
 * properly using Luhn validation.
 * Client-side validation only, it checks that the format is valid, not
 * that the value is correct.
 */
- (BOOL)isNumberValid;

/**
 * Convenience method to check that the expiration date is formatted properly
 * and is not in the past.
 * Client-side validation only, it checks that the format is valid, not
 * that the value is correct.
 */
- (BOOL)isExpirationDateValid;

/**
 * Convenience method to check if the CVV number is formatted properly
 * Client-side validation only, it checks that the format is valid, not
 * that the value is correct.
 */
- (BOOL)isCVVValid;

/**
 * Method to charge a card with the details in the chargeDictionary
 *
 * chargeDictionary parameters:
 *      amount - NSDecimalNumber containing amount to charge
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of currency code, defaults to USD
 */
- (void)chargeCardWithParameters:(NSDictionary *)chargeDictionary
                         success:(void(^)(CFTCharge *charge))success
                         failure:(void(^)(NSError *error))failure;

/**
 * Method to create a card token that can be saved and used later.
 * On success the cardToken variable contains a value that can
 * be stored and used later.
 */
- (void)tokenizeCardWithSuccess:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure;

@end
