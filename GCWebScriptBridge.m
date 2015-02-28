//
// groovyAPI Library
// @author: Jake Wise (GroovyCarrot) <wise.jake@live.co.uk>
//

#import "GCWebScriptBridge.h"

@implementation GCWebScriptBridge

-(void)userContentController:(WKUserContentController*)controller didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.body isKindOfClass:[NSDictionary class]] || !message.body[@"action"] || !message.body[@"callback"] || ![message.body[@"action"] isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSLog(@"[GroovyCarrot] groovyAPI (%p) received message %@", self.view, message.body[@"action"]);

    if (message.body[@"action"][@"read"]) {
        NSString *_file = [message.body[@"action"][@"read"] stringByReplacingOccurrencesOfString:@"../" withString:@""];
        _file = [@"/var/mobile/Documents/" stringByAppendingString:_file];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_file]) {
            NSError *error;
            NSString *file = [[NSString stringWithContentsOfFile:_file encoding:NSUTF8StringEncoding error:&error] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            if (file) {
                NSString *javascript = [NSString stringWithFormat:@"%@(decodeURIComponent(\"%@\"));", message.body[@"callback"], file];
                [self.view evaluateJavaScript:javascript completionHandler:nil];
            }
            else {
                NSLog(@"[GroovyCarrot] groovyAPI (%p) failed to read file %@: %@", self, _file, error.description);
            }
        }
    }
}

+(GCWebScriptBridge*)groovifyThisConfig:(WKWebViewConfiguration*)configuration {
    for (NSString *script in configuration.userContentController.userScripts) {
        if ([script isEqual:@"groovyAPI"]) {
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

