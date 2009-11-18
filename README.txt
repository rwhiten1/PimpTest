= pimp_test

http://github.com/rwhiten1/PimpTest

== DESCRIPTION:

This will be (hopefully) a lightweight integration and functional automated testing web application.  It
will be lightweight in the sense that it uses Rack to plug into any ruby based web server, doesn't require
any databases, and should be very easy to install, like:

gem install pimp_test (this won't work right this moment, since their isn't anything to GEM up)

then to run it (on local host) $> ruby pimp_app.rb

== FEATURES/PROBLEMS:

Not much in the way of functionality, but things to come:
- Drag existing test fixtures from a repository to add tests to a page
- Add ui components to a page (Text, Headings, Tables, etc.)
- Run test components on a page individually
- Run an entire page
- Editable properties that the test running environment will maintain and make available to all fixtures
- Page level variables, inherited by child pages
- Ability to run tests locally (where pimp_test is installed) or in a distrubuted fashion
- Test locking, so that once a test is started, it has to finish before it can be started again.
- Better results reporting than FitNesse, well, not better, just more persistent (maybe some data gathering)

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* FIX (list of requirements)

== INSTALL:

* FIX (sudo gem install, anything else)

== LICENSE:

(The MIT License)

Copyright (c) 2009 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
