Purple Shoes
==========

Porting [Green Shoes](https://github.com/ashbb/green_shoes) with **JRuby** and **SWT**. 

Install JRuby and Purple Shoes for Windows
-----------------------------------------

- download and install [JRuby 1.6.7 Windows Executable](http://jruby.org/download)
- jruby --1.9 -S gem install purple_shoes

The [swt](http://rubygems.org/gems/swt) gem will be installed automatically.

Install JRuby and Purple Shoes for Linux and OS X
-----------------------------------------------

- install [rvm](http://beginrescueend.com/)
- rvm install jruby
- gem install purple_shoes

Look at the command line help
-----------------------------

```
jruby --1.9 -S pshoes -h
```

<pre>
Usage: pshoes (options or app.rb)
  -m, -men     Open the built-in English manual.
  -mjp         Open the built-in Japanese manual.
  -v           Display the version info.
  -h           Show this message.
</pre>

**Note**: If you set an environment variable like this: `set JRUBY_OPTS=--1.9`, you can do just only `pshoes -h`.


Note to OSX Users
-----------------

You'll need to pass an extra argument to JRuby's JVM for SWT to work on OSX.  Your command line should look like this:

```
jruby -J-XstartOnFirstThread --1.9 sample2.rb
```


Open the built-in manual
-----------------------

```
jruby --1.9 -S pshoes -m
```

![snapshot](https://github.com/ashbb/purple_shoes/raw/master/manual.png)
