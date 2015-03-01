//
// groovyAPI Library
// @author: Jake Wise (GroovyCarrot) <wise.jake@live.co.uk>
//

#import "GCWebScriptBridge.h"

@implementation GCWebScriptBridge

- (void)userContentController:(WKUserContentController*)controller didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.body isKindOfClass:[NSDictionary class]] || !message.body[@"action"] || !message.body[@"callback"]) {
        return;
    }

    NSString *_method;
    SEL selector;

    if ([message.body[@"action"] isKindOfClass:objc_getClass("NSString")]) {
        void (*perform_action)(id, SEL, NSString *callback);

        _method = [NSString stringWithFormat:@"%@_callback:", message.body[@"action"]];

        selector = NSSelectorFromString(_method);
        if (![self respondsToSelector:selector]) {
            return;
        }

        NSLog(@"[GroovyCarrot] groovyAPI (%p) %@[%@]", self.view, _method, message.body[@"callback"]);

        perform_action = (void (*)(id, SEL, NSString *callback)) [self methodForSelector:selector];
        perform_action(self, selector, message.body[@"callback"]);
        return;
    }

    if (![message.body[@"action"] isKindOfClass:objc_getClass("NSDictionary")]) {
        return;
    }

    void (*perform_action)(id, SEL, NSString *arg, NSString *callback);
    NSDictionary *action = message.body[@"action"];

    if (action.allKeys.count < 1) {
        return;
    }

    for (NSString *key in action.allKeys) {
        _method = [NSString stringWithFormat:@"%@:callback:", key];
        selector = NSSelectorFromString(_method);
        if (![self respondsToSelector:selector]) {
            continue;
        }

        NSLog(@"[GroovyCarrot] groovyAPI (%p) %@[%@, %@]", self.view, _method, action[key], message.body[@"callback"]);

        perform_action = (void (*)(id, SEL, NSString *arg, NSString *callback)) [self methodForSelector:selector];
        perform_action(self, selector, action[key], message.body[@"callback"]);
    }
}

- (void)eval:(NSString*)js {
    [self.view evaluateJavaScript:js completionHandler:nil];
}

- (void)read:(NSString*)_file callback:(NSString*)_callback {
    NSLog(@"[GroovyCarrot] groovyAPI (%p) reading file", _file);

    _file = [_file stringByReplacingOccurrencesOfString:@"../" withString:@""];
    _file = [@"/var/mobile/Documents/" stringByAppendingString:_file];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_file]) {
        return;
    }

    NSError *error;
    NSString *file = [[NSString stringWithContentsOfFile:_file encoding:NSUTF8StringEncoding error:&error] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (file) {
        NSString *javascript = [NSString stringWithFormat:@"%@(decodeURIComponent(\"%@\"));", _callback, file];
        [self eval:javascript];
    }
    else {
        NSLog(@"[GroovyCarrot] groovyAPI (%p) failed to read file %@: %@", self, _file, error.description);
    }
}

- (void)getWidgetWeather_callback:(NSString*)_callback {
    NSString *wwDataString = [NSString stringWithContentsOfFile:@"/var/mobile/Documents/widgetweather.xml" encoding:NSUTF8StringEncoding error:nil];
    if (!wwDataString) {
        return;
    }

    NSError *err;
    NSDictionary *wwData = [XMLReader dictionaryForXMLString:wwDataString error:&err];

    if (!err) {
        NSString *javascript;
        javascript = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:wwData options:nil error:nil] encoding:NSUTF8StringEncoding];
        javascript = [NSString stringWithFormat:@"%@(%@);", _callback, javascript];
        [self eval:javascript];
    }
    else {
        NSLog(@"[GroovyCarrot] groovyAPI (%p) could not read in XML: %@", self.view, err.description);
    }
}

+ (GCWebScriptBridge*)groovifyThisConfig:(WKWebViewConfiguration*)configuration {
    for (NSString *script in configuration.userContentController.userScripts) {
        if ([script isEqualToString:@"groovyAPI"]) {
            return nil;
        }
    }

    GCWebScriptBridge *handler = [[GCWebScriptBridge alloc] init];
    [configuration.userContentController addScriptMessageHandler:handler name:@"groovyAPI"];
    
    // Add the groovyAPI object.
    WKUserScript *add_gAPIObj = [[objc_getClass("WKUserScript") alloc]
        initWithSource:@"\
            var groovyAPI = new Object();\
            groovyAPI.do = function(action,callback){\
                if (typeof callback == 'function') {\
                    groovyAPI.tempcallback = callback;\
                    callback = 'groovyAPI.tempcallback';\
                }\
                window.webkit.messageHandlers.groovyAPI.postMessage({'action':action,'callback':callback});\
            };"
        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly:NO
    ];
    [configuration.userContentController addUserScript:add_gAPIObj];

    return handler;
}

+(int)getMemoryUsed {
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),TASK_BASIC_INFO,(task_info_t)&info,&size);
    if( kerr == KERN_SUCCESS ) {
        return (int)info.resident_size;
    }
    return 0;
}

@end

