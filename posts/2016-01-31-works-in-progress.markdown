---
title: Works in Progress
postType: project
---

#### CS:GO Nade Guides (ghcjs, reflex-dom, servant)

The first version is [here](/nades). (Type "cache". Click the thumbnails to zoom in.)

It's a client-only single-page app that fetches a [simple text format](/nades/public/cache.txt) via XHR, parses it, and provides a UI for the result.
I designed it this way so I could write guides in a normal text editor and host everything on GitHub.

I'm still working on a second version, which will be a complete web app. In its current state:

* Authed CRUD for Nades and NadeLists using servant (servant-server + persistent + esqueleto, ghcjs-servant-client)
* Cookie-based sessions using clientsession
* Authentication via Google Sign-In button
* Barebones web UI for sign-in and interacting with Nades endpoints

Source code: [csgo-guides](https://github.com/ublubu/csgo-guides)
    
#### Tile Rider Web App

I'm working on a web (servant, ghcjs + reflex-dom) version of my Tile Rider game. I want users to be able to create, play, and share puzzles. So far, I've written some client-side code for game and editor UI.

#### Exploring Client-Side Development with GHCJS and reflex-dom

I'm filling in the gaps between my understanding of reflex-dom and what is possible with client-side javascript like React. Two main points of interest are client-side routing (e.g. hooking into pushState and popState) and transitions.

My experiments are [here](https://github.com/ublubu/webapp-reflex).
The mockup of client-side routing works. I just need to connect it to real browser functions.
And once reflex-dom gets an analogue of React's componentDidMount event, my attempt at a simple transition should work as well.

I also have a few typeclass-powered combinators to simplify some of the syntax in composing a reflex-dom app.

Source code: [webapp-reflex](https://github.com/ublubu/webapp-reflex)
