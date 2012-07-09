tf2.pug.na - A TF2 pug bot in Ruby
==================================

Installation
------------

This bot requires the following packages:
-ruby 1.9.2
-ruby devel
-rubygems
-sqlite3
-cinch 1.1.3 (http://www.mediafire.com/?k479m3p9pxwje7c | extract and place it in your .gem/gems dir)
-zlib
-zlib devel

There are a few gems required to run the bot, and the bundler gem will install and manage these gems for you. Open terminal and run the following command:

    gem install bundler

Once bundler is installed, run the command:

    bundle install


Configuration
-------------

Configure your bot by editing cfg/constants.cfg. Please use another channel and nick for testing your bot, so as to reduce the number of conflicts.


Execution
---------

Navigate to the "src" directory and run the bot with the command:

    ruby bot.rb 
