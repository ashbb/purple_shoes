Purple Shoes
==========

This is a trial repository for porting Green Shoes with JRuby and SWT. 

**NOTE: Just for my personal learning repository.**

Install JRuby and SWT for Windows
----------------------------------

- download [JRuby 1.6.5.1 Windows Executable](http://jruby.org/download)
- install JRuby into c:\jruby
- cd c:\jruby
- C:\jruby>jruby --1.9 c:\jruby\bin\gem install swt

Install JRuby and SWT for OS X
------------------------------

- install [rvm](http://beginrescueend.com/)
- rvm install jruby
- gem install swt

Run a sample snippet
--------------------

- cd c:\tmp
- git clone git://github.com/ashbb/purple_shoes.git
- cd purple_shoes\samples
- jruby --1.9 sample2.rb


Note to OSX Users
-----------------

You'll need to pass an extra argument to JRuby's JVM for SWT to work on OSX.  Your command line should look like this:

```
jruby -J-XstartOnFirstThread --1.9 sample2.rb
```


Snapshot
---------

![snapshot](https://github.com/ashbb/purple_shoes/raw/master/snapshots/sample2.png)
