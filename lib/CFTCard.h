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
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import "CFTAPIResource.h"
#import "CFTEnum.h"
@class CFTCharge;

@interface CFTCard : CFTAPIResource <NSCopying>

@property (nonatomic, readonly) NSString *first6;
@property (nonatomic, readonly) NSString *last4;
@property (nonatomic, readonly) NSString *cardTypeString;
@property (nonatomic, readonly) NSString *expirationMonth;
@property (nonatomic, readonly) NSString *expirationYear;
@property (nonatomic, readonly) CFTCardType cardType;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *cardToken;
@property (nonatomic, readonly) NSString *vaultID;

/*!
 * @brief Charge the card associated with a Vault ID
 * @param vaultID NSString of the Vault ID to charge
 * @param chargeDictionary NSDictionary containing charge details
 * @param success Block containing CFTCharge, executed on success
 * @param failure Block containing NSError, executed on failure
 * @discussion Method to charge a card with the details in the chargeDictionary.
 * chargeDictionary parameters:
 *      amount - NSDecimalNumber containing amount to charge
 *      callback_url - Optional - NSURL of callback URL to trigger
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of currency code, defaults to USD
 *      merchant_id - Optional - NSString of Braintree submerchant ID
 *      service_fee - Optional - NSDecimalNumber containing the fee to charge
 * Added in 3.2
 */
+ (void)chargeVaultID:(NSString *)vaultID
       withParameters:(NSDictionary *)chargeDictionary
              success:(void(^)(CFTCharge *charge))success
              failure:(void(^)(NSError *error))failure;

/*!
 * @brief Charge the card
 * @param chargeDictionary NSDictionary containing charge details
 * @param success Block containing CFTCharge, executed on success
 * @param failure Block containing NSError, executed on failure
 * @discussion Method to charge a card with the details in the chargeDictionary.
 * chargeDictionary parameters:
 *      amount - NSDecimalNumber containing amount to charge
 *      callback_url - Optional - NSURL of callback URL to trigger
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of currency code, defaults to USD
 *      merchant_id - Optional - NSString of Braintree submerchant ID
 *      service_fee - Optional - NSDecimalNumber containing the fee to charge
 * Updated in 3.0
 */
- (void)chargeCardWithParameters:(NSDictionary *)chargeDictionary
                         success:(void(^)(CFTCharge *charge))success
                         failure:(void(^)(NSError *error))failure;

/*!
 * @brief Authorize a card for later capture of a charge
 * @param authorizeDictionary NSDictionary containing the authorization details
 * @param success Block containing CFTCharge, executed on success
 * @param failure Block containing NSError, executed on failure
 * @discussion Method to authorize a card for later capture.
 * authorizeDictionary parameters:
 *      amount - NSDecimalNumber containing amount to charge
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of currency code, defaults to USD
 *      merchant_id - Optional - NSString of Braintree submerchant ID
 *      service_fee - Optional - NSDecimalNumber containing the fee to charge
 */
- (void)authorizeCardWithParameters:(NSDictionary *)authorizeDictionary
                            success:(void(^)(CFTCharge *charge))success
                            failure:(void(^)(NSError *error))failure;

/*!
 * @brief Tokenize a card
 * @param success Block executed on tokenize success
 * @param failure Block containing NSError that is executed on tokenize failure
 * @discussion Method to create a card token that can be saved and used later.
 * On success the cardToken variable contains a value that can
 * be stored and used later.
 */
- (void)tokenizeCardWithSuccess:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure;

/*!
 * @brief Valut a card
 * @param success Block executed on vaulting success
 * @param failure Block containing NSError that is executed on vaulting failure
 * @discussion Method to create a card vault ID that can be saved and used later.
 * On success the cardVaultID variable contains a value that can
 * be stored and used later.
 * Added in 3.0
 */
- (void)vaultCardWithSuccess:(void(^)(void))success
                     failure:(void(^)(NSError *error))failure;

/*!
 * @brief Check for card equality
 * @param card CFTCard to compare
 * @return BOOL indicating if the cards are equal
 * @discussion Checks if 2 cards are equal. Cards are considered equal if
 * the card numbers are the same.
 * Added in 3.0
 */
- (BOOL)isEqualToCard:(CFTCard *)card;

/*!
 * @brief Internal use only
 */
- (NSDictionary *)dictionaryData:(NSData *)parameter;

@end
