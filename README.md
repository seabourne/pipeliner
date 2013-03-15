# Pipeliner
Pipeliner is a package for creating complex, event driven job pipelines (flows).  Pipeliner makes it easy to:

* Work on data coming from any data source
* Handle complex data transformations
* Combine multiple data sources into a single stream
* Gracefully handle data errors and restart runs without loosing data
* Easily output the processed data in a number of ways  

## Flows
Pipeliner is designed to create information 'flows', a combination of inputs, processors and outputs.  Inputs can be conceivably anything, from an API client to a database connection.  Processors do something with the data, like translate a field or clean data.  Outputs take the final data and make it available somehow, through an API for example.  The flow mediates information transfer between each component, saving state so that information is retained even when there is an error.

## Basic Usage
```
pipeliner = require 'pipeliner'

flow = new pipeliner.Flow
input = new pipeliner.Module () ->
	# generate your data here
	this.done(data)

processor = new pipeliner.Module (data) ->
	# do something to the data
	this.done(data)

output = new pipeliner.Module (data) ->
	# publish the data somehow
	this.done(data)

flow.addModules([input, processor, output])

input.doNext(processor).doNext(output)

input.process()		
```

## Advanced Usage
The example above is pretty simple, and most uses will need to use a more advanced approach.

### Events
Each Module is an event dispatcher, triggering specific events when changes to the processing flow happen.  There are two events you'll want to bind to in order to monitor flow processing.

* *complete*: 
* *error*:

### Creating Processors
In order to create more full featured processors, you'll want to extend the core Module class to add your own functionality by overriding the processData function.

```
pipeliner = require 'pipeliner'

Module = pipeliner.Module

class MyProcessor extends Module

	processData: (data)	->
		#process data somehow
		@done data
```

When the data processing is done, call the `@done` method, passing in the processed data as the argument.  The next processor in the chain will received the passed data.

### Triggering Errors
Trigger errors using the `@error` method, passing in the error text.

## Working with Jobs

## License
Copyright (c) 2012 Seabourne <info@seabourneinc.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.