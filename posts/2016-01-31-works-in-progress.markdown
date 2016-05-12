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
