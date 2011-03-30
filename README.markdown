Prolixity
=========

Prolixity is my personal project to design a programming language for iOS devices. Even at an early stage, the language is mostly complete and can be used for small programs.

The syntax of the language is designed to be usable on a touch-screen keyboard: It requires few special symbols, and auto-correcting spell checkers on mobile devices will be friendly with its keywords and identifiers. The runtime system directly piggybacks on the Objective-C runtime, and therefore can access any exposed Objective-C API.

With the design goals, the language will be useful for quick scripting on mobile devices. It can also be used as an embedded scripting language for your own app, so that you can enable user scripting or allow a "dev mode" for easier debugging.


Building the Demo App
---------------------

Please clone this project and run the app on either the iOS Simulator or your iPad. I have supplied a few example snippets that should give a good overview of this language and the design goals.


Note on Building From A Fresh Clone
-----------------------------------

	$ cd parser
	$ make
	$ cd ..


Note on Building with Xcode 3.2.5
---------------------------------

Prolixity is developed with Xcode 4. The project contains targets of two platforms: iOS and Mac OS X, and Xcode 3.2.5 doesn't handle it well. To build the project with Xcode 3.2.5, please do this:

1.  After opening the project, Opt-click on the Overview dropdown list (the list that shows the available SDKs, Opt-click expands the list)

2.  Choose "Base SDK"

Then the project should build, first the Lemon parser, an OS X command line tool, then the rest of the targets, which are iOS apps.

Cf. http://lists.apple.com/archives/xcode-users/2010/Jun/msg00308.html


Copyright
---------

Copyright (c) 2011 Lukhnos D. Liu (lukhnos at lukhnos dot org)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


