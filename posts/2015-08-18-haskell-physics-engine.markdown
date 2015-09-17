---
title: 2D Physics in Haskell
postType: project
---

[shapes](https://github.com/ublubu/shapes) is a constraint-based physics engine that currently features convex polygons, non-penetration with baumgarte stabilization, friction, solution caching, static and non-rotating objects, and AABB broadphase elimination.
It's based on GDC slide decks I found online.

I've always been curious about game development.
I also wanted to write some Haskell to run in real-time.

<iframe width="420" height="315" src="https://www.youtube.com/embed/-2e-YW07bo0" frameborder="0" allowfullscreen></iframe>

I'm looking forward to using this codebase as a playground for learning about profiling and optimizing Haskell. I would also like to explore more exotic approaches - I've heard great things about writing languages/compilers in Haskell.

This project has been a fun experience in incrementally growing a codebase from a simple core.
In addition to pursuing better performance, I also plan to add support for new shapes, new constraints, and new developer interfaces (game physics EDSL?).

Source code:
[library](https://github.com/ublubu/shapes), [demo app](https://github.com/ublubu/shapes-demo)