# LogBox

Our ColdBox application uses the built-in LogBox module for logging. This allows us to centralize management of our logs and allow more flexibility, simplicity, and power when logging or tracing is needed.

By default, you will have access to the root logger and can make a log which will appear in the default configuration. In your handlers, you can make a log by using the builtin logbox variable, getting the root logger and using one of the severity levels to make your log. `logbox.getRootLogger().warn('Your log message', ['your log data', 'goes hear'])`.

## Resources

[https://logbox.ortusbooks.com/](https://logbox.ortusbooks.com/)

[https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/logbox](https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/logbox)

[https://shiftinsert.nl/logbox-basic-concepts-and-configuration/](https://shiftinsert.nl/logbox-basic-concepts-and-configuration/)

## Configuration

Configuration of LogBox is set in the `\config\Coldbox.cfc` file.

Our configuration looks something like the below.

``` cfml
logBox = {
    // Define Appenders
    appenders : {
    	coldboxTracer : { class : "coldbox.system.logging.appenders.ConsoleAppender" },
    	debugLog :  {
    		class : "RollingFileAppender",
    		properties : {
    		  filePath : "logs",
    		  fileName : "debug",
    		  autoExpand : true,
    		  fileMaxSize : 2000,
    		  fileMaxArchives : 3
    		},
    		levelMin : '4',
    		levelMax : '4'
    	},
    	errorLog : {
    		class : "RollingFileAppender",
    		properties : {
    			filePath : "logs",
    			fileName : "error",
    			autoExpand : true,
    			fileMaxSize : 2000,
    			fileMaxArchives : 3
    		},
    		levelMax : '2'
    	},
    	handlerAppender : {
    		class : "RollingFileAppender",
    		properties : {
    			filePath : "logs",
    			fileName : "handlerLog",
    			autoExpand : true,
    			fileMaxSize : 2000,
    			fileMaxArchives : 3
    		},
    		levelMax : '2'
    	}
    },
    // Root Logger
    root      : { levelmax : "DEBUG", appenders : "debugLog,errorLog" },
    // Implicit Level Categories
    categories = {
    	"handlerLog" : {
    	  appenders: "handlerAppender",
    	  levelMax: "debug"
    	}
    }
};
```

### Appenders

[https://logbox.ortusbooks.com/configuration/configuring-logbox/logbox-dsl#appenders](https://logbox.ortusbooks.com/configuration/configuring-logbox/logbox-dsl#appenders)

The appenders are places that the logs will go. We are currently using file appenders, logs will be appended to a file and archived after the specified length.

```CFML
debugLog : {
	class : "RollingFileAppender",
	properties : {
	filePath : "logs",
	fileName : "debug",
	autoExpand : true,
	fileMaxSize : 2000,
	fileMaxArchives : 3
},
	levelMin : '4',
	levelMax : '4'
}
```

This appender is called “debugLog”. This file will be located in the root logs folder and be prefixed with “debug” in the file name. The logs will ‘expand’ which means that the log data will not be truncated. After 2000 lines, it will be zipped and archived. There will me a max of 3 archives.

Level refers to the debug level.

* NONE = -1: no logging at all
* FATAL = 0 : the application’s situation is catastrophic, it should stop
* ERROR = 1: a severe issue is stopping functions, but application still runs.
* WARN = 2: Unexpected problem: not sure if it will happen again, but no serious harm to your application yet. Eventually you need to look at it.
* INFO = 3: Normal behaviour, these messages just tell you what happened during normal operation.
* DEBUG =4: Information necessary to diagnose, troubleshoot or test the application.

### Categories

Categories are custom loggers you can use in your code to log in a specific way.

``` CFML
categories = {
	"handlerLog" : {
		appenders: "handlerAppender",
		levelMax: "debug"
	}
}
```

We have a “handlersLog” that uses the “handlerAppender” with a max logging level of “debug”.

You can inject this logger in your handler and use it lo log to a specific file.

```CFML
component extends="coldbox.system.EventHandler" {
property name="handlerLog" inject="logbox:logger:handlerLog";
```

Then in your functions, you can call the appropriate logger (debug, warn, error…) `handlerLog.error('test handler log', {data: prc.welcomeMessage});`
