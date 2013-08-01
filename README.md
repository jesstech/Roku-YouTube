Roku YouTube
=============


A YouTube app for the Roku DVP that supports automatic video quality switching, 
user favorites, searches and more based on the [Picasa Web Albums Roku app](http://bitbucket.org/chrishoffman/roku-picasa/) 
by [Chris Hoffman](http://bitbucket.org/chrishoffman).

The channel performs OAuth authentication to access your YouTube account via an 
address I've set up on my domain running Chris Hoffman's excellent [Google Apps Engine
RokuLink project](https://bitbucket.org/chrishoffman/appengine-rokulink), great for
serving your own OAuth requests if my server goes down.

###[https://owner.roku.com/add/3K5SKG](https://owner.roku.com/add/3K5SKG)

Installation
============

Enable development mode on your Roku Streaming Player with the following remote 
control sequence:

    Home 3x, Up 2x, Right, Left, Right, Left, Right

When devleopment mode is enabled on your Roku, you can install dev packages
from the Application Installer which runs on your device at your device's IP
address. Open up a standard web browser and visit the following URL:

    http://<rokuPlayer-ip-address> (for example, http://192.168.1.6)

[Download the source as a zip](https://bitbucket.org/jesstech/roku-youtube/get/master.zip) - 
unfortunately the manifest file needs to be in the root of the archive uploaded to the Roku, 
so you need to extract this zip, and then recompress the first level folder as its own zip and 
upload that to your Roku.

Due to limitations in the sandboxing of development Roku channels, you can only
have one development channel installed at a time.

Advanced
========

### Debugging

Your Roku's debug console can be accessed by telnet at port 8085:

    telnet <rokuPlayer-ip-address> 8085

### Building from source

The [Roku Developer SDK](http://www.roku.com/developer) includes a handy Make script 
for automatically zipping and installing the channel onto your device should you make
any changes.  Just add the project to your SDK's `examples/source` folder and run the
`make install` command from that directory via your terminal.


Contributing
------------

Want to contribute? Great! Go ahead and download the source, play around with it, fork it 
if you like, whatever.  I've only added basic functionality, so if you think you can help
out I'd love to have your contribution!