# Pipeliner
Pipeliner is a package for creating complex, event driven job pipelines (flows).  Pipeliner makes it easy to:

* Work on data coming from any data source
* Handle complex data transformations
* Combine multiple data sources into a single stream
* Gracefully handle data errors and restart runs without loosing data
* Easily output the processed data in a number of ways  

# Flows
Pipeliner is designed to create information 'flows', a combination of inputs, processors and outputs.  Inputs can be conceivably anything, from an API client to a database connection.  Processors do something with the data, like translate a field or clean data.  Outputs take the final data and make it available somehow, through an API for example.  The flow mediates information transfer between each component, saving state so that information is retained even when there is an error.

# Usage
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

flow.start()		
```

# License
Copyright (c) 2012 Seabourne <info@seabourneinc.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.