[Source on GitHub](https://github.com/ublubu/webapp-reflex/tree/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client)

## Keeping track of the current route as a `Dynamic`

The application should respond to new routes without reloading:

* User clicks `<a>`.
* Other interaction within the app
* Browser forward and back buttons
  
The app should also be able to display a URL separate from the logical route it uses internally. For example, a simplified URL may be used to share just the current focus in a deeply nested page - without encoding any of the context.

### Build a top-level `(Dynamic t route)` and extract the URL path from it.

    foreign import javascript unsafe "history.pushState($1, '', $2)"
      historyPushState :: JSVal -> JSString -> IO ()

    foreign import javascript unsafe "window.onpopstate = function (x) { $1(x.state); }"
      setWindowOnpopstate :: Callback (JSVal -> IO ()) -> IO ()
  
    -- create a reflex `Event` from a JavaScript callback
    callbackEvent :: (MonadWidget t m, FromJSVal r)
                  => (Callback (JSVal -> IO ()) -> IO ())
                  -> m (Event t r)
  
    historyWidget :: (MonadWidget t m, FromJSVal r, ToJSVal r)
                  => (r -> String)
                  -> Event t [r] -- pushstate events
                  -> m (Event t r) -- popstate events
    historyWidget toPath pushStates = mdo
      let push route = do
            jvRoute <- liftIO $ toJSVal route
            liftIO $ historyPushState jvRoute (JSS.pack $ toPath route)
      performEvent_ $ mapM_ push <$> pushStates
      callbackEvent setWindowOnpopstate

[History.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/History.hs)
[Callback.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Callback.hs)

`historyWidget` provides an interface to the browser's `history` object. I use it to store a structured representation of which "page" I'm on - equivalent to the route of the page.

    pathnameHistoryWidget :: (MonadWidget t m, FromJSVal r, ToJSVal r)
                          => (String -> r)
                          -> (r -> String)
                          -> Event t [r] -- pushstate events
                          -> m (Dynamic t r) -- current state
    pathnameHistoryWidget fromPath toPath pushStates = do
      location <- liftIO getWindowLocation
      path <- fmap JSS.unpack . liftIO $ getPathname location
      popStates <- historyWidget toPath pushStates
      holdDyn (fromPath path) $ leftmost [popStates, fmap last pushStates]

[History.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/History.hs)

*Note: I should switch from `[r]` to `(NonEmpty r)`*

`pathnameHistoryWidget` fetches the pathname when the application first loads, so it knows which page to start with. Afterwards, it feeds the application with routes from browser history `popstate`s and `pushState`s bubbled up through the application (e.g. the user clicks an `<a>`).

-----

## Composing widgets

In React, all rendering code is written at the constant level. This means all your usual logic and control structures like `if` and `case` still work. For example:

    render: function() {
      // ...
      return (
        <div>
          { someContent ? renderSomeContent(someContent) : null}
        </div>
      );
    }
    
In reflex-dom, application code is aware of how values change over time, so an analogous expression would be more complex.

### A simplifying assumption: `EventContainer`

Let's assume that all widgets return `()` or an `Event` stream.
Widgets can't do anything until they're built, so any constant (including the initial value of a `Behavior`/`Dynamic`) can be owned by the parent. Put another way: What is the output of a widget that only sometimes exists?

*Note: One answer I haven't dealt with yet:
`(MonadWidget t m) => Dynamic t (Maybe x) -> (x -> m (Dynamic t a)) -> m (Dynamic t (Maybe a))`*

Following this idea, I'll pretend that most widgets return a collection of `Event` streams.
In many ways, this collection can be treated as a single stream:

    class (MonadWidget t m) => EventContainer t m a where
      ecJoin :: Event t a -> m a

    instance (MonadWidget t m) => EventContainer t m (Event t a) where
      ecJoin evts = switch <$> hold never evts

    instance (EventContainer t m a, EventContainer t m b) => EventContainer t m (a, b) where
      ecJoin dVal =
        (,) <$> (ecJoin $ fst <$> dVal) <*> (ecJoin $ snd <$> dVal)

[Combinators/Class.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Combinators/Class.hs)

Actually, I have a few more typeclasses, so it looks like this:

    class (Neverable a, Switchable t a, Leftmostable a, MonadWidget t m) => EventContainer t m a

    class Neverable a where
      ecNever :: a
    
    class (Reflex t) => Switchable t a where
      ecSwitch :: Behavior t a -> a
    
    class Leftmostable a where
      ecEither :: a -> a -> a
      ecLeftmost :: [a] -> a

    -- this is really just Monoid
    class Neverable a => Catenable a where
      ecCat :: a -> a -> a
      ecConcat :: [a] -> a
    
    type EventContainer' t m a = (Catenable a, EventContainer t m a)

[Combinators/Class.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Combinators/Class.hs)

### Combinators with `EventContainer`

Boolean tests:

    -- use an eventing widget whenever the Dynamic is True
    dWhen :: (EventContainer t m a) => Dynamic t Bool -> m a -> m a

    -- use an eventing widget whenever the Dynamic contains a value
    dWhenJust :: (EventContainer t m a)
              => Dynamic t (Maybe x)
              -> (Dynamic t x -> m a)
              -> m a

    -- equivalent of Control.Monad `when` for EventContainers
    whenE :: (MonadWidget t m, Neverable a) => Bool -> m a -> m a

    -- `if` statement for combining eventing widgets
    dIf :: (EventContainer t m a, EventContainer t m b)
        => Dynamic t Bool
        -> m a
        -> m b
        -> m (a, b)
    dIf' :: (EventContainer t m a) => Dynamic t Bool -> m a -> m a -> m a

[Combinators.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Combinators.hs)
    
Case statements:
    
    data DynCase t s a where
      -- case statement using lens
      DCase :: Getting (First x) s x -> (Dynamic t x -> a) -> DynCase t s a
      -- TODO: other kinds of cases
      --       e.g. (s -> Maybe x) -> (Dynamic t x -> a) -> DynCase t s a
    
    dCase :: (EventContainer t m a)
          => Dynamic t s
          -> [DynCase t s (m a)]
          -> m a
    
    -- Example usage:
    rootWidget mUserId makeHref routeD cache =
      dCase routeD
      [ _AllModulesPage `DCase` \page -> allModulesWidget makeHref page cache
      , _MyModulesPage `DCase` \page -> myModulesWidget makeHref page cache
      , _ModulePage `DCase` moduleWidget mUserId makeHref cache
      , _ModuleCreatePage `DCase` moduleCreationWidget cache
      ]

[Combinators.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Combinators.hs)
[RootWidget.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Meathead/RootWidget.hs)
      
*Note: My current implementation of dCase doesn't ensure that at most one case is active at any time. By extension, I also don't have a catch-all case yet.*
    
-----

## Building an application based on `(Dynamic t route)` and collecting `pushState`s

Any change in application state that affects the URL must be bubbled up to the history widget. This allows the browser's "back" and "forward" buttons to function as expected.
These state changes are fed back into the application via a `(routeD :: Dynamic t route)`.
This `routeD` acts as the single repository of route-related state for the entire application.

### Analogous repositories of other application-level state

    -- turn a list of requests into servant-client API calls
    handleModuleRequests :: [ModuleRequest] -> ServIO [ModuleCacheUpdate]

    applyCacheUpdate :: ModuleCacheUpdate -> ModuleCache -> ModuleCache

    moduleCache :: (MonadWidget t m)
                => ModuleCache
                -> Event t [ModuleRequest]
                -> m (Dynamic t ModuleCache)
    moduleCache cache0 reqE = do
      resE <- performWithLog handleModuleRequests reqE
      foldDyn applyCacheUpdates cache0 resE

[ModuleCache.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Meathead/ModuleCache.hs)
      
Here is a(n overly) simple cache for interacting with "Modules" stored behind an API.
It reacts to requests bubbled up through the app and provides a simple read interface `:: (Dynamic t ModuleCache)`. This exactly parallels the history widget interface.

This example doesn't do much, but it could dedupe, ignore, or otherwise optimize the `[ModuleRequest]`, periodically refresh old entries, or receive push updates from the server.

### Bubbling requests up through the widget hierarchy

Requests can originate anywhere in the widget tree. They need to bubble up past the root of the tree to the request handler widgets.

Here's an app that uses a history widget and an API interface widget:

    main = mainWidgetWithHead headEl $ mdo
      -- request-handler / state-management widgets
      pageStateD <- pathnameHistoryWidget fromPath toPath pushStates
      moduleCacheD <- moduleCache emptyModuleCache moduleRequests
    
      -- visible widgets
      Bubbling (pushStates, moduleRequests) () <-
        rootWidget makeHref pageStateD moduleCacheD
    
      return ()

[Main.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Main.hs)

Currently, I'm collecting requests manually, using this type to help me:

    data Bubbling t r a = Bubbling { _bBubble :: r , _bContents :: a }
    
    -- app-specific
    type BubbleApp t e =
      Bubbling t (Event t [PageState], Event t [ModuleRequest]) e

[Combinators.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Combinators.hs)
[App.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Meathead/App.hs)
    
The `_bBubble` is requests to bubble up to the top, and `_bContents` is everything else.

Still, there's nothing (but hlint) to stop me from missing some bubbles so their requests don't make it to the top. Also, it's ugly:

    rootWidget mUserId makeHref routeD cache = do
      navBubbles <- el "div" $ do
        allClicks <- appLink makeHref (pageAllModules 0 100) "all"
        text " "
        myClicks <- appLink makeHref (pageMyModules 0 100) "mine"
        return $ ecConcat [allClicks, myClicks]
      pageBubbles <- dCase routeD
        [ _AllModulesPage `DCase` \page -> allModulesWidget makeHref page cache
        , _MyModulesPage `DCase` \page -> myModulesWidget makeHref page cache
        , _ModulePage `DCase` moduleWidget mUserId makeHref cache
        , _ModuleCreatePage `DCase` moduleCreationWidget cache
        ]
      return $ ecConcat [pageBubbles, navBubbles]

[RootWidget.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Meathead/RootWidget.hs)
      
I'd like to use the monad to collect bubbles for me. Then I can focus on the `Event`s used locally.

### Composing "applications"

The root-level interface of an application looks something like this:

    rootWidget :: (MonadWidget t m)
               => Dynamic t (PageState -> Text) -- make href (<a> hover/copy)
               -> Dynamic t PageState           -- state from history widget
               -> Dynamic t ModuleCache         -- state from API interface widget
               -> m (Bubbling t (Event t [PageState], Event t [ModuleRequest]) ())

[RootWidget.hs](https://github.com/ublubu/webapp-reflex/blob/b861b0aa5d230725c2c8ed9b24cb58b2a21ac112/client/src/Meathead/RootWidget.hs)

The inputs are externally-managed state, and the outputs are requests to modify external state.
It should be straightforward to use such an interface to incorporate one app into another.

One area of note is the translation between (app-specific) `PageState` and a URL path:

* A sub-application is unaware of the parent's path scheme, so the parent must provide this information.
* It may not be straightforward to incorporate sub-applications' sub-paths into a parent application's path.

### "nubDyn" to avoid unnecessary re-rendering on a state change

When the history widget updates `routeD`, it's possible that only a small piece of the page state changed.
Furthermore, it is possible that only a small, deeply-nested widget needs to know about this change.

*Note: In fact, it's likely that this deeply-nested widget is the source of the state change. i.e. The `pushState` bubbled all the way up only to be sent back by the history widget. This seems excessive, but I haven't thought of a good alternative yet.*

Actually, in the branches of the widget tree, we can avoid unnecessary churn in the DOM.
So long as the shape of the state remains the same (e.g. same constructor in a sum type), the structural combinators `dWhen`, `dWhenJust`, `dIf`, `dCase`, etc should continue using the same widget.

*Caveat: I think `dWhenJust` and `dCase` behave this way. I know `dWhen` doesn't. I'll have to test and fix them all.*

The only unnecessary churn would occur at the leaves, where the actual value of the `Dynamic` is rendered to an element. As such, it may be necessary to use `nubDyn` at the leaves.

This doesn't address unnecessary computation in the branches. I'm not sure how to prune the widget tree based on what part of the state changed, or if that's even worth doing.

##[Project on GitHub](https://github.com/ublubu/webapp-reflex)
