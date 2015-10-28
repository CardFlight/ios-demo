/*
 *****************************************************************
 * CFTPaymentView.h
 *
 * Copyright (c) 2015 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <UIKit/UIKit.h>
@class CFTCard;

@protocol CFTPaymentViewDelegate <NSObject>

@required

/*!
 * @brief Callback triggered when a valid card is available
 * @param card CFTCard that was generated
 * @discussion Required protocol method that gets called whenever the
 * manual entry receives enough valid input to generate a
 * credit card object.
 * Added in 2.0
 */
- (void)keyedCardResponse:(CFTCard *)card;

@optional

/*!
 * @brief Callback triggered when invalid data is entered
 * @discussion Optional protocol method that gets called whenever the
 * currently entered keyed information can not create a valid card.
 * Added in 2.0.4
 */
- (void)invalidKeyedResponse;

@end

@interface CFTPaymentView : UIView

@property (nonatomic, weak) id<CFTPaymentViewDelegate> delegate;

/*!
 * @brief Constructor with option to prompt for a zip code in manual entry
 * @param frame CGRect of the payment view
 * @param zipEnabled BOOL option to enable zip code capture
 * @return CFTPaymentView instance
 * @discussion Custom manual entry can be created with an optional zip code
 * field in addition to the standard fields.
 * Updated in 1.8.3
 */
- (instancetype)initWithFrame:(CGRect)frame enableZip:(BOOL)zipEnabled;

/*!
 * @brief Resign first responder from all fields
 * @discussion Sends the custom manual entry textfields the resignFirstResponder
 * message.
 * Added in 1.5.1
 */
- (void)resignAll;

/*!
 * @brief Clear all input from all fields
 * @discussion Clears all the input from the textfields and returns it to its
 * initial state.
 * Added in 1.5.1
 */
- (void)clearInput;

/*!
 * @brief Set keyboard appearance of custom manual entry textfields
 * @param keyboardAppearance UIKeyboardAppearance enumeration of keyboard type
 * @discussion Assigns a UIKeyboardAppearance to the custom manual entry textfields.
 * UIKeyboardAppearanceDefault is used by default.
 * Added in 1.5.1
 */
- (void)useKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance;

/*!
 * @brief Set font for custom manual entry textfields
 * @param newFont UIFont of font to use
 * @discussion Assigns a font to use for the custom manual entry textfields.
 * Uses bold system font size 17 by default. Passing nil reenables the default font.
 * Added in 1.5.1
 */
- (void)useFont:(UIFont *)newFont;

/*!
 * @brief Set font color for custom manual entry textfields
 * @param newColor UIColor of color to use
 * @discussion Assigns a color to use for the font for the custom manual
 * entry textfields. Black is used by default. Passing nil reenables the default font color.
 * Added in 1.5.1
 */
- (void)useFontColor:(UIColor *)newColor;

/*!
 * @brief Set the font alert color for custom manual entry textfields
 * @param newColor UIColor of color to use
 * @discussion Assigns a color to use for the font when the validation fails.
 * A red color (253, 0, 17) is used by default. Passing nil reenables the default alert font color.
 * Added in 1.5.1
 */
- (void)useFontAlertColor:(UIColor *)newColor;

/*!
 * @brief Set the border color for custom manual entry
 * @param newColor UIColor of color to use
 * @discussion Assigns a new color to the textfield border.
 * Black is used by default. Passing nil reenables the default border color.
 * Added in 1.5.1
 */
- (void)useBorderColor:(UIColor *)newColor;

@end
