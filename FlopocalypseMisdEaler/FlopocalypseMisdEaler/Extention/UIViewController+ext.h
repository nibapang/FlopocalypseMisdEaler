//
//  UIViewController+ext.h
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ext)

- (void)misdEalerSetupNavigationBar;

// Present an alert with the given title and message using misdEaler naming convention.
- (void)misdEalerPresentAlertWithTitle:(NSString *)title message:(NSString *)message;

// Add a child view controller to the specified container view using misdEaler naming convention.
- (void)misdEalerAddChildViewController:(UIViewController *)childViewController toContainerView:(UIView *)containerView;

- (BOOL)misdEalerNeedLoadAdBannData;

- (NSString *)misdEalerHostUrl;

- (void)misdEalerShowAdView:(NSString *)adurl;

@end

NS_ASSUME_NONNULL_END
