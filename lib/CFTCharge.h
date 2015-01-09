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
#import "CFTSessionManager.h"
#import "CFTAPIResource.h"

@interface CFTCharge : CFTAPIResource

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *referenceID;
@property (nonatomic) BOOL isRefunded;
@property (nonatomic) BOOL isVoided;
@property (nonatomic) NSDecimalNumber *amountRefunded;
@property (nonatomic) NSDate *created;
@property (nonatomic) NSDictionary *metadata;

/**
 * Refund a charge by passing in the charge token
 * and amount to refund in dollars and cents.
 */
+ (void)refundChargeWithToken:(NSString *)token
                    andAmount:(NSDecimalNumber *)amount
                      success:(void(^)(CFTCharge *charge))success
                      failure:(void(^)(NSError *error))failure;

/**
 * Capture a previously authorized charge
 * by passing the charge token and the amount
 * to capture. If the amount is nil then amount
 * of the original authorization will be captured.
 */
+ (void)captureChargeWithToken:(NSString *)token
                     andAmount:(NSDecimalNumber *)amount
                       success:(void(^)(CFTCharge *charge))success
                       failure:(void(^)(NSError *error))failure;

/**
 * Void a charge and post to the CardFlight servers
 */
- (void)voidChargeWithSuccess:(void(^)())success
                      failure:(void(^)(NSError *error))failure;

// ******************** DEPRECATED ********************

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
