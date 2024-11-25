/********* FacebookLogin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookLogin : CDVPlugin
@end

@implementation FacebookLogin

- (void)loginWithFacebook:(CDVInvokedUrlCommand*)command {
    NSDictionary* options = [command.arguments objectAtIndex:0];
    NSString* appId = [options objectForKey:@"appId"];

    if (appId == nil || [appId length] == 0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Facebook App ID is missing"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    // Configure Facebook SDK
    [[FBSDKApplicationDelegate sharedInstance] initializeSDK];
    [FBSDKSettings.sharedSettings setAppID:appId];

    // Use FBSDKLoginManager for Facebook login
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithPermissions:@[@"public_profile", @"email"]
                     fromViewController:self.viewController
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        CDVPluginResult* pluginResult = nil;

        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        } else if (result.isCancelled) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Login cancelled"];
        } else {
            NSDictionary *response = @{
                @"userId": result.token.userID,
                @"token": result.token.tokenString,
                @"permissions": result.grantedPermissions.allObjects,
                @"declinedPermissions": result.declinedPermissions.allObjects
            };
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
