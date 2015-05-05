Swell - Swift Logging
=====

A logging utility for Swift and Objective C.

##Features

* Turn on logging during development, turn them off when building for the App Store
* Enable or disable logging for specific classes
* Different log levels allow for finer-grained control of logging within a class
* Log to the console, text file, or a custom location
* Log message isn't computed when logging is disabled (thanks to the @auto_closure feature)

##Maintenance Note

I actively use this for my own projects, and every new project I create includes this.  It works well for my needs. However, I develop iOS apps only in my spare time, which is not a lot.  This can affect my response time to pull requests.

##Basic Usage

###Using the shared logger

The shared logger is the simplest, quickest way to get started using Swell.  

```swift
class ContactService {

    func getContact(name: String) {
        Swell.info("Retrieving contact for \(name)")
        ...
    }

}
```

```
INFO: Retrieving contact for Steve
 ```


###Using a named logger

Using a named logger allows for better control over which logs of which classes you want to see during development.  A typical name would match the class using it, making it easy to see which class is logging which statement.

```swift
class ContactService {

    let logger = Swell.getLogger("ContactService")

    func getContact(name: String) {
        logger.debug("Retrieving contact for \(name)")
        ...
    }

}
```

```
DEBUG ContactService: Retrieving contact for Steve
 ```
 
###Logging complex statements
Sometimes you need extra code in order to generate the information you need to log, but you don't need to execute the same code when you build for the App Store.  Using Swell's closure functions is the answer to this scenario.

```swift
class ContactService {

    let logger = Swell.getLogger("ContactService")

    func getContact(name: String) {
        ...
        logger.trace { 
        	let city = getCityFor(name)
            return "Retrieving contact for \(name) of \(city)"
        }
        ...
    }

}
```

The code in the closure will only execute if the statement will be logged according to how the Logger is configured.


###Disable all loggers

Are you building for the App Store?  Don't forget to disable your loggers.

```swift
Swell.disableLogging()
```

See also the next section, which uses an optional ```.plist``` file to configure Swell.


##Configuration

For more control over how Swell loggers behave, add a Swell.plist resource file.  You can then configure which log levels to enable, where to send the log output, and what information to include for each log.

###Root configuration
The root configuration specifies the behavior for all Swell loggers.  

![```Swell.plist``` example](Documentation/plist01.png "Swell.plist")

All keys are optional.  However, if you specify "file" for the log location, you should provide a filename for the log file.  Any unspecified values will revert to built-in defaults.

###Named logger configurations

You can specify a different configuration for named loggers.  As with the root configuration, the configuration details are optional, and any unspecified values will use what the root configuration has for it.

In the ```plist``` file, create a Dictionary type, and use the logger name as the Key.  The configuration in this Dictionary will be used for that logger.

![```Swell.plist``` with configuration for a named logger](Documentation/plist02.png "Swell.plist with configuration for a named logger")

In the example above, MyStableClass is configured to only produce logs that are error level or higher, and will use a different log output format than other loggers.  Since a log location wasn't provided, it will use the same location specified in the root configuration.

To use this logger, specify its name when you create your Logger instance.


```swift
let logger = Swell.getLogger("MyStableClass")
```
 

##Roadmap

Let's be honest - we have a long list of features for anything we write, long before we're done writing them.

However, my goal is to keep Swell as simple as possible, while allowing the configurability I've been looking for since I started iOS development.

So here's list of To Do for Swell:

* More documentation
* Improved Date format in FlexFormatter

That said, the Swell library is alpha software.  Things may change (drastically).  However, I'm already using it extensively for my projects, so I have plenty of incentives to keep the public API stable.
