# groovyAPI+ for iOS8
This software was intended to provide iOS theme developers that use HTML/JavaScript an
easy to use JavaScript-Objective C API to retrieve data on the device that would
otherwise be inaccessible from a widget, and perform various other actions to achieve a
more interactive and integrated experience.

On iOS 7 groovyAPI worked by hooking the `UIWebDocumentView` and injecting into the
`WebView` `windowScriptObject` property using the largely undocumented and private
`WebScriptObject` and `JSObject` APIs. This allowed adding *[a raft of
functionality](http://groovycarrot.co.uk/groovyapi/)* into the JavaScript interpeter at
runtime on all `UIWebView` instances running on the OS.

Since my time to work on iOS tweaks has become limited since iOS 7, I was hoping that
opening up the code to other developers would improve progress. Unfortunately when iOS
8, and it's subsequent first public jailbreak were released, the old WebScript
interface seemed to have been depreciated. Not only that but Apple had (albeit much
later than most had hoped) exposed WebKit as a public API, with a far superior
web-rendering `WKWebView` interface that resolved many of the performance, and
memory-related crashing complains that I was swamped with on a daily basis.

Now groovyAPI+ is an updated version designed to utilise the `WKWebView` and uses 
methods that are [public and documented](https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKWebView_Ref).
Since writing a proof of concept here, I haven't had time to go back reimplementing the
functionality mentioned previously, or solving some of the new issues presented by
using the public WebKit API. Namely, the main issues preventing public release are:
- After the device has entered deep sleep, all JavaScript timers are killed by the OS
  (as you would expect) however this breaks most themes that use timers to track clocks
  and animations. My initial solution of trying to reload the view did not work, and
  that's about all that I've managed to try there.
- Reading a file from the filesystem is not possible using JavaScript due to a bug in
  the version of WebKit bundled on iOS 8. This bug is worked around in this project
  already by implementing the below JS function to read a file from the Documents
  directory.
```javascript
groovyAPI.do(
  {'read': 'widgetweather.xml'},
  function(data) {
    // handle data.
  }
);
```
  While this does provide a solution to the problem, it's not ideal. This means every
  theme that reads a file needs to be rewritten to use this function in order to work.

So at the moment I've held back on updating my HTML theme platforms
GroovyLock/GroovyBoard until a time where these issues have been addressed; and I can
release a tweak public without receiving complaints on a daily basis because their
lockscreen cannot reenact the entire Return of the Jedi Death Star battle scene without
freezing and crashing.

Check it out, all improvements are welcome, and I apologise that I might not adhere to
many Objective C coding standards.

## License
Copyright 2015 Jake Wise

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

