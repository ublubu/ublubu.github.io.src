---
title: 2D Physics in Haskell
postType: project
---

[shapes](https://github.com/ublubu/shapes) is a constraint-based physics engine that currently features convex polygons, non-penetration with baumgarte stabilization, friction, solution caching, static and non-rotating objects, and AABB broadphase elimination.
It's based on GDC slide decks I found online.

I've had great success optimizing the engine. The current demo comfortably handles 225 objects (1000-2000 constraints) at 100fps.
I accomplished this primarily by:

* optimizing special-case matrix multiplication
* using Template Haskell to generate vector arithmetic code with unboxed numbers
* changing my solver algorithm to allow caching in unboxed vectors
* pervasive inlining
* caching some shape queries for contact generation

There are still more optimizations I can implement.
For example, there are some ideas from [Bullet](http://bulletphysics.org) that I'd like to try.
And I haven't even started parallelizing things yet.

<iframe width="420" height="315" src="https://www.youtube.com/embed/DYzf4zBK90o?list=PLmozfF6FosKjmPMnlPoVbWosiExbD0SUF" frameborder="0" allowfullscreen></iframe>

This project has been a fun experience in incrementally growing a codebase from a simple core.
In addition to pursuing better performance, I also plan to add support for new shapes, new constraints, and new developer interfaces (game physics EDSL?).

Source code:
[shapes](https://github.com/ublubu/shapes)
