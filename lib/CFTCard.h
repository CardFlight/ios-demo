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
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import "CFTAPIResource.h"
#import "CFTEnum.h"
@class CFTCharge;

@interface CFTCard : CFTAPIResource <NSCopying>

@property (nonatomic, readonly) NSString *last4;
@property (nonatomic, readonly) NSString *expirationMonth;
@property (nonatomic, readonly) NSString *expirationYear;
@property (nonatomic) CFTCardProcessor cardType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *encryptedSwipedCardNumber;
@property (nonatomic, copy) NSData *encryptedSwipeData;
@property (nonatomic, copy) NSString *cardToken;

/*
 * Method to charge a card with the details in the chargeDictionary.
 * Legacy method for swiped cards, current method for manually entered cards.
 *
 * chargeDictionary parameters:
 *      amount - NSDecimalNumber containing amount to charge
 *      description - Optional - NSString of charge description
 *      customer_id - Optional - NSString of customer ID being charged
 *      currency - Optional - NSString of currency code, defaults to USD
 *      merchant_id - Optional - NSString of Braintree submerchant ID
 *      service_fee - Optional - NSDecimalNumber containing the fee to charge
 */
- (void)chargeCardWithParameters:(NSDictionary *)chargeDictionary
                         success:(void(^)(CFTCharge *charge))success
                         failure:(void(^)(NSError *error))failure;

/*
 * Method to authorize a card for later capture.
 *
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

/*
 * Method to create a card token that can be saved and used later.
 * On success the cardToken variable contains a value that can
 * be stored and used later.
 */
- (void)tokenizeCardWithSuccess:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure;


/*
 * Internal use only
 */
- (NSDictionary *)dictionaryData:(NSData *)parameter;

@end
