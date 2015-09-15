---
title: functipede - Flow Graphs in JavaScript
postType: project
---

I've been working with Robert Timpe on implementing a game engine as a flow graph.
I think it might be possible to use C++ template metaprogramming to make Intel TBB's flow graph library easier to use by making it look like function composition.

I wrote functipede to see how it feels to write a game this way.
I model flow graphs (and individual nodes) as a set of input callbacks and a set of output callbacks.
This makes it simple to compose a flow graph from smaller pieces.
In addition to graph composition, I've implemented tools for creating both stateful and stateless nodes/graphs from functions.

I used functipede for a few days, but I found it very difficult to keep track of the edges in and out of a graph. 
The abstraction seems usable, but the tooling is definitely not.
I think something like Unreal Engine 4's Blueprint graphical scripting might be what's needed to make graph-building code fun.

Source code: [functipede](https://github.com/ublubu/functipede)

*UPDATE:* Later on, I came across arrows and an associated syntax implemented for Haskell. I haven't tried it yet, but I would like to use Yampa (arrowized functional reactive programming) for a game one day.