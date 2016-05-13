---
title: Yahoo Magazines Frontend Team (Feb 2014 - Mar 2015)
postType: job
---

I worked at Yahoo for just over a year on the digital magazines (platform) team.
I wrote JavaScript (with React) for the nodejs server and the web client.

[Yahoo Style](http://www.yahoo.com/style),
[Yahoo Food](http://www.yahoo.com/food),
[Yahoo Tech](http://www.yahoo.com/tech),
[Yahoo Beauty](http://www.yahoo.com/beauty),
[etc](http://www.yahoo.com/movies)

In addition to my feature work, I applied principles from functional programming to create design patterns that eliminate avenues for complexity and bugs.
I wrote 
[this blog post](http://ublubu.tumblr.com/post/109544244542/a-reactive-perspective-on-flux)^1^
explaining one important pattern after my team used it for a few months.

The most important application of my design patterns was my integration of a particularly awkward ad service.
The original implementation was fragile and made it difficult to add new ad configurations to our magazines.

My encapsulation of the ad service made it possible to implement multiple new ad configurations without increasing code complexity.
Furthermore, engineers on my team could now quickly add or modify ad configurations without deep knowledge of the underlying service.
Ad integration issues also became much simpler to debug.

Another team actually picked up my ad integration code and maintained it as a library for other Yahoo properties to use.

^1^My blog post: [A Reactive Perspective on Flux](http://ublubu.tumblr.com/post/109544244542/a-reactive-perspective-on-flux)
