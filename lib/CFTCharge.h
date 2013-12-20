/*
 *****************************************************************
 * CFTCharge.h
 *
 * Is returned after a successful charge is made.
 * Contains all the information about a charge and has the ability
 * to refund it, either partially or in full
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <Foundation/Foundation.h>
#import "CardFlight.h"
#import "CFTAPIResource.h"

@interface CFTCharge : CFTAPIResource

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *referenceID;
@property (nonatomic) BOOL isRefunded;
@property (nonatomic) NSDecimalNumber *amountRefunded;
@property (nonatomic) NSDate *created;

/**
 * Refund a charge and post to the CardFlight servers
 *
 * chargeDictionary parameters:
 *      amount - NSDecimalNumber of the amount to charge
 *      description - Optional - NSString of charge description
 *      currency - Optional - NSString of currency code, defaults to USD
 */
- (void)refundChargeWithParameters:(NSDictionary *)chargeDictionary
                           success:(void(^)())success
                           failure:(void(^)(NSError *error))failure;

@end
