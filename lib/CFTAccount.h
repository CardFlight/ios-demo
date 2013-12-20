//
//  Account.h
//  CardFlightLibrary
//
//  Created by Tim Saunders on 9/20/13.
//  Copyright (c) 2013 Filip Andrei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFTAccount : NSObject

@property (nonatomic, strong) NSString *apiToken;
@property (nonatomic, strong) NSString *accountToken;

/**
 * Create the account object with the api token and account token
 * @param apiToken The API Token associated with this developer account
 * @param accountToken The Merchant Account Token associated with this developer account
 */
-(id) initWithApiToken:(NSString *)apiToken andAccountToken:(NSString *)accountToken;


@end
