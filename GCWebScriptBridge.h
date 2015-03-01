//
// groovyAPI Library
// @author: Jake Wise (GroovyCarrot) <wise.jake@live.co.uk>
//

#import <objc/runtime.h>
#import <mach/mach.h>
#import <substrate.h>
#import <WebKit/WebKit.h>
#import <XMLReader.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBLockScreenView.h>
#import <SpringBoard/SBLockScreenScrollView.h>
#import <SpringBoard/SBLockScreenNotificationListView.h>
#import <SpringBoard/SBLockScreenBounceAnimator.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconModel.h>
#import <PrivateFrameworks/SpringBoardServices.framework/SBAppLaunchUtilities.h>

#import <SpringBoard/SBLockScreenPluginController.h>
#import <PrivateFrameworks/SpringBoardUI.framework/SBAwayViewPluginController.h>

#import "CTRegistration.h"
#import "RadiosPreferences.h"
#import <WidgetWeather2.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface GCWebScriptBridge: NSObject <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *view;

+(GCWebScriptBridge*)groovifyThisConfig:(WKWebViewConfiguration*)configuration;

@end


