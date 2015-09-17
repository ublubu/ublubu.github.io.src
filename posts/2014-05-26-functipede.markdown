---
title: functipede - Flow Graphs in JavaScript
postType: project
---

[functipede](https://github.com/ublubu/functipede) is a set of tools for composing flow graphs in JavaScript.
I model all flow graphs (even single nodes) each as a set of input callbacks and a set of output callbacks.
This makes it simple to compose a flow graph from smaller pieces.
In addition to graph composition, I've implemented tools for creating both stateful and stateless nodes/graphs from functions.

Source code: [functipede](https://github.com/ublubu/functipede)

I've been working with Robert Timpe on implementing a C++ game engine as a flow graph.
I think it might be possible to use C++ template metaprogramming to make Intel TBB's flow graph library easier to use by making graph composition look like function composition.
I wrote functipede as a quick prototype to see if I actually wanted to write flow graphs that way.

I used functipede for a few days, but I found it very difficult to keep track of the edges in and out of a graph. 
The abstraction seems usable, but the tooling is definitely not.
I think something like Unreal Engine 4's Blueprint graphical scripting might be what's needed to make graph-building code fun.

*UPDATE:* Later on, I came across [arrows](https://en.wikipedia.org/wiki/Arrow_(computer_science)) and an associated syntax implemented for Haskell. I haven't tried it yet, but I would like to use Yampa (arrowized functional reactive programming) for a game one day.