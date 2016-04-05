---
title: 2D Physics in Haskell
postType: project
---

[shapes](https://github.com/ublubu/shapes) is a constraint-based physics engine that currently features convex polygons, non-penetration with baumgarte stabilization, friction, solution caching, static and non-rotating objects, and AABB broadphase elimination.
It's based on GDC slide decks I found online.

I've always been curious about game development.
I also wanted to write some Haskell to run in real-time.

<iframe width="420" height="315" src="https://www.youtube.com/embed/DYzf4zBK90o?list=PLmozfF6FosKjmPMnlPoVbWosiExbD0SUF" frameborder="0" allowfullscreen></iframe>

This project has been a fun experience in incrementally growing a codebase from a simple core.
In addition to pursuing better performance, I also plan to add support for new shapes, new constraints, and new developer interfaces (game physics EDSL?).

Source code:
[shapes](https://github.com/ublubu/shapes)
