## Signals and Signal Functions

Stores are like signals. Each store is a value that changes over time.

A React document (also, whatever other store listeners you have) is a signal function. It is a stateless\* transform of its input signals -- the current value of the input signals (current store state) goes in, and out comes a document to render and a (maybe) collection of events.

\*Consider React as including a store to hold the ```this.state``` of each component.

There is a clear boundary here between the stateful and stateless aspects of the application. This boundary should be as simple as possible, to prevent mistakes.

-----

## Simplify the Interface

Stores should expose their entire state.

If consumers have an unanticipated need for a particular piece of store state, they shouldn't have to wait for a code change in the store.

A convenient way to expose the entire state is to maintain a single ```state``` variable -- accessible via ```getState``` and ```setState```. This lets us generalize the following about stores:

* serialize/deserialize
* connect store to listener (signal to signal function)
* track state changes

'Generalize' means we get to write the code once and use it across all stores.

Without this simplification, these points become:

*serialize/deserialize*

* Each store needs its own serialize/deserialize.
* It is possible not to serialize the entire state.
    * More opportunity for mistakes.
    * No longer discourages redundant data in state.
    * Causes mismatch between server-side prerender and client-side re-render -- loading flicker.

*connect store to listener*

* Listeners require store-specific code to extract state.
    * The boundary between stateful and stateless code can only be abstracted on a per-store basis.
    * In signal-speak: There is no longer a general way to sample the current value of a signal. Feeding a signal into a signal function now requires custom code for each signal.

*track state changes*

* It's possible to have an arbitrary number of mutators on a store.
    * Each mutator needs its own change-tracking (emit a 'change' event to the listeners)
    * Multiple mutators may need to occur simultaneously (i.e. an action mutates two fields in the store). Need logic to defer/dedupe the 'change' event until all mutators have been called.

### Extracting/Transforming Data from Store State

In a signal function, we have access to the current value (of the ```state``` variable) of each input signal. That value might not be in a convenient format.

> We may even need to combine the value with other data, but that's obviously not a good argument for adding functionality to the store.
> > Yes, I know that indexing into the value is technically 'combining' it with the index, i.e. 'other data'. (`getSpecificValue` in example below)
> > Just pretend it says `store2.getTopResult()` instead.

If we allowed ourselves to directly access the store from inside the listener, we might add additional accessors onto the store. That risks breaking the generalizability of our 'connect store to listener' code.

 An example of how this could be a problem:

     //... somehow listen to a collection of stores
     listenToStores: ['store1'],

     render: function() {
         //... somehow get a handle on store2
         //        e.g. this.props.context.getStore('store2')
         var specificValue = store2.getSpecificValue(someParams);
         //...
     }

 In the example, we use the generalized mechanism to listen to `store1`, but we rely on data from `store2` as well. We need to re-render when `store2` changes, but we aren't listening to `store2`. This kind of bug can be hard to catch.

 *Option 1*: One way to reduce the risk is to only use a small number of controller views to listen to stores. This would limit the space these bugs could occur in.
 An extension of this solution is to use only one controller view that listens to all stores. This more drastic measure would eliminate the risk entirely.

 > Limiting ourselves to a small number of controller views doesn't really solve our 'the value might not be in a convenient format' problem. If we extracted store state to fit each component's needs, we could quickly create a very complicated controller view.

 *Option 2*: Another option is to write helper functions to use the monolithic values -- e.g. wrapping them in a construct that provides the necessary accessors/transforms. This option lets you use the enhanced access/transform functionality even when you don't have access to the store itself. *[I like this way.]*

#### Option 3: Revisiting `getState` and 'Connect Store to Listener'

Actually, even if we don't have `getState`, we can still generalize the process of a listener executing when a store changes. We just can't generalize the way store state is extracted for the listener to execute on.

This isn't a huge deal. In each listener, we can manually extract state from the store using whatever accessors are available.

In general, we still can't expect a store's built-in accessors to provide the perfect format for every listener. (Arguably, we shouldn't even want to complicate the store with all that listener-specific code.) The most we can expect is that the built-in accessors provide *all the data* each listener needs -- via `getState`, for example.

If we need the equivalent of `getState` anyway, why consider 'Option 3'? We wrote some internal accessors in the store and we'd like to reuse that code. The answer is to pull those accessors into a separate module per 'Option 2'.
