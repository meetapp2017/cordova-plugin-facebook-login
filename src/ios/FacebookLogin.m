/********* FacebookLogin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

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

    // Конфигуриране на Facebook SDK
    [[FBSDKApplicationDelegate sharedInstance] initializeSDK];
    [FBSDKSettings.sharedSettings setAppID:appId];

    // Проверка дали потребителят вече е влязъл
    if ([FBSDKAccessToken currentAccessToken]) {
        // Ако е влязъл, веднага взимаме профилната информация и връщаме резултат
        [self getUserProfileWithCommand:command];
    } else {
        // Ако не е влязъл, започваме процеса на вход
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
                // След успешен вход, веднага взимаме профилната информация
                [self getUserProfileWithCommand:command];
                return;
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

// Метод за извличане на профилната информация
- (void)getUserProfileWithCommand:(CDVInvokedUrlCommand*)command {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,email" }];
    
    // Използване на актуализирания тип на блока
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting> connection, id result, NSError *error) {
        CDVPluginResult* pluginResult = nil;

        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        } else {
            // Събиране на данни за потребителя
            NSString *userName = result[@"name"];
            NSString *userEmail = result[@"email"];
            NSString *userId = result[@"id"];

            // Подготовка на резултата
            NSDictionary *response = @{
                @"id": userId ? userId : [NSNull null],
                @"name": userName ? userName : [NSNull null],
                @"email": userEmail ? userEmail : [NSNull null]
            };

            // Връщане на резултата към JavaScript
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        }

        // Изпращане на резултата или грешката обратно към JavaScript
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
