//
// groovyAPI Library
// @author: Jake Wise (GroovyCarrot) <wise.jake@live.co.uk>
//

#import "GCWebScriptBridge.h"
#import <WebKit/WebKit.h>

static WKWebView * (* original_$WKWebView$initWithFrame$configuration)(WKWebView *, SEL, CGRect frame, WKWebViewConfiguration * configuration);

static WKWebView * groovy_$WKWebView$initWithFrame$configuration(WKWebView * self, SEL _cmd, CGRect frame, WKWebViewConfiguration* configuration) {
    NSLog(@"[GroovyCarrot] groovyAPI (%p) groovifying navigator", self);
    
    GCWebScriptBridge *handler = [GCWebScriptBridge groovifyThisConfig:configuration];
    if (handler) {
        self = original_$WKWebView$initWithFrame$configuration(self, _cmd, frame, configuration);
        handler.view = self;
    }

    return self;
}

__attribute__((constructor)) static void groovyAPI_MSRuntime() {{
    MSHookMessageEx(objc_getClass("WKWebView"), @selector(initWithFrame:configuration:), (IMP)&groovy_$WKWebView$initWithFrame$configuration, (IMP*)&original_$WKWebView$initWithFrame$configuration);
}}
