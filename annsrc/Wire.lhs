Annotated Source
----------------

For the sake of completeness, I include here the entire annotated source for the
wire arrow transformer, which is written in Literate Haskell\cite{lang:haskell}.

The `Wire` type uses existential types. For the sake of simplicity, we pull in
the full language extension for generalized algebraic data types\cite{gadts}.

> {-# LANGUAGE GADTs #-}

Again for the sake of simplicity, rather than writing out arrow combinators in
full, we pull in the language extension for Paterson's arrow
notation\cite{arrowNotation}.

> {-# LANGUAGE Arrows #-}

\pagebreak[1]

The `ArrowWriter`, `ArrowReader` and `ArrowState` instances need the flexible
instance language features, so we pull those in too.

> {-# LANGUAGE FlexibleInstances #-}
> {-# LANGUAGE MultiParamTypeClasses #-}
> {-# LANGUAGE UndecidableInstances #-}

\pagebreak[1]

We export the main `Wire` type from the module:

> -- |Very simple FRP state wires, using existential state.
> module Control.FRP.Wire(Wire,

Accumulation belongs in a typeclass, so we export the class and the one function
it contains.

>                         ArrowWire,
>                         accumulate,

To "remove the transformer" we have the `stepWire` function, and as a matter of
convenience we also have `runWire`.

>                         runWire,
>                         stepWire) where

\pagebreak[1]

The `id` and `.` definitions from `Prelude` are specialised to `Hask` rather
than general categories, so we hide those so we can take the generalised
versions from `Control.Category`.

> import Prelude hiding (id, (.))
>
> import Control.Category

The core of the arrow combinator library is in `Control.Arrow` (other than the
category typeclass) so we import that too.

> import Control.Arrow

\pagebreak[1]

From Paterson's `arrows` package we also import the arrow transformer mechanism
and the typeclasses.

> import Control.Arrow.Transformer
> import Control.Arrow.Operations

\pagebreak[1]

Since accumulation works on idempotent monoids, we need both the `Data.Monoid`
module from `base` and the `Data.Monoid.Idempotent` module from the `idempotent`
package described in Section\ \ref{sec:idempotent}.

> import Data.Monoid
> import Data.Monoid.Idempotent

\pagebreak[1]

Since arrows can be improved with the mechanism from the `arrow-improve` package
described in Section\ \ref{sec:improve}, we also export later an instance for
the `ArrowWire` typeclass for improved arrows.

> import Control.Arrow.Improve

\pagebreak[2]

`Wire` is the primary data-type exported from this module.

> -- |The Wire transformer, transforming an arrow a to a wire on that arrow.
> data Wire a b c where

Its first constructor, `WLift`, is the constructor for lifted values from the
underlying arrow type.

>   WLift :: a b c -> Wire a b c

The second constructor, `WState`, is the actual meat of the data type: for an
existential type `s` here hidden behind the GADT mechanism, it is a Moore
machine with b and c as the input and output alphabets respectively, and s for
the set of states. The second parameter is the initial state.

>   WState :: a (b, s) (c, s) -> s -> Wire a b c

Semantically, `WLift` is just `WState` with `s` set to `()`, the unit type -- it
is here a separate constructor to avoid the memory usage associated with `(a,
())` or `((), a)`, which is more than a lone `a`.

The `runWire` combinator is a matter of convenience, and runs a wire which takes
a unit and input and output indefinitely, feeding back to itself. When the
underlying arrow is `Hask` this is admittedly rather pointless. In other arrows,
such as `Kleisli IO`, however, this can run a full program.

> -- |Run an IO-free wire, running indefinitely.
> runWire :: (Arrow a) => Wire a () () -> a () ()
> runWire (WLift a) = ioLoop
>   where ioLoop = a >>> ioLoop
> runWire (WState f s) = const ((), s) ^>> ioLoop >>^ const ()
>   where ioLoop = f >>> ioLoop

\pagebreak[1]

The `stepWire` combinator is the main mechanism for running computations in the
arrow, and in essence translates a `Wire a b c` into `Automaton a b c` less the
newtype.

> -- |Run a single step of a wire, essentially transforming the Wire into an
> -- automaton.
> stepWire :: (Arrow a) => Wire a b c -> a b (c, Wire a b c)
> stepWire w@(WLift a) = a >>^ (\x -> (x, w))
> stepWire (WState f s) = (\x -> (x, s)) ^>> f >>^ (\(x, s') -> (x, WState f s'))

\pagebreak[2]

The `Category` instance for `Wire` is in principle uncomplicated, although one
case of composition ends up being a little long-winded.

> instance (Arrow a) => Category (Wire a) where

For the identity element, since this is an arrow transformer, we just lift the
identity element from the underlying arrow.

>   id = WLift id

The composition of two lifted values is similarly simple.

>   WLift f . WLift g = WLift (f . g)

The composition of a lifted computation with a stateful one is
relatively simple: while it results in a stateful computation, the
state is only kept from the single stateful component. The lifted
computation is made to 'ignore' the state with `first`.

>   WLift f . WState g isg = WState (first f . g) isg
>   WState f isf . WLift g = WState (f . first g) isf

The composition of two stateful computations is the trickiest case. For the sake
of convenience, we write it with Paterson's arrow notation. The state is
actually the product of the two lower states, essentially a pair containing the
"state of the left computation" and the "state of the right computation".

The arrow notation cleans up most of the hairy details. We run the computation
`g` with the state pattern-matched from the composite state, getting the interim
result and the new state for the right-hand side, and then do similarly with `f`
from the left-hand side. We then pass along the result of the left computation
along with the new state product.

>   WState f isf . WState g isg = WState h (isf, isg)
>     where h = proc ~(x, (sf, sg)) -> do ~(y, sg') <- g -< (x, sg)
>                                         ~(z, sf') <- f -< (y, sf)
>                                         id -< (z, (sf', sg'))

\pagebreak[1]

The `Arrow` instance is, by-and-large, uncomplicated and short.

> instance (Arrow a) => Arrow (Wire a) where

The `arr` function, lifting values from `Hask`, is very simple: we use `WLift`
and borrow `arr` from the underlying arrow.

>   arr = WLift . arr

As with many other combinators, in the `WLift` case for `first` we
can use the implementation from the underlying arrow directly.

>   first (WLift f) = WLift (first f)

The stateful case is actually fairly simple: the type of the state does not
change, all that changes is some moving around of the association and order of
the tuples to fit the type of `first` in the underlying arrow.

>   first (WState f s) = WState (exchange ^>> first f >>^ exchange) s
>     where exchange ~((x, y), z) = ((x, z), y)

\pagebreak[3]

The `ArrowChoice` instance is virtually identical to the `Arrow` instance, just
using the obvious cases of sum types rather than products.

> instance (ArrowChoice a) => ArrowChoice (Wire a) where
>   left (WLift f) = WLift (left f)
>   left (WState f s) = WState (exchange ^>> left f >>^ unexchange) s
>     where exchange (Left x, y) = Left (x, y)
>           exchange (Right x, y) = Right (x, y)
>           unexchange (Left (x, y)) = (Left x, y)
>           unexchange (Right (x, y)) = (Right x, y)

\pagebreak[1]

The `ArrowLoop` instance, which gives us the power of recursion, looks
remarkably similar to the implementations for `first` and `left`: some simple
permutations on the types, and the implementation from the underlying arrow.

> instance (ArrowLoop a) => ArrowLoop (Wire a) where
>   loop (WLift f) = WLift (loop f)
>   loop (WState f s) = WState (loop $ exchange ^>> f >>^ exchange) s
>     where exchange ~((a, b), c) = ((a, c), b)

\pagebreak[1]

The arrow transformer implementation, which lifts computations from the
underlying arrow, is simply a matter of applying the WLift constructor.

> instance (Arrow a) => ArrowTransformer Wire a where
>   lift = WLift

\pagebreak[2]

We export the typeclass of wire-like operations. In principle, we could allow
this to be the same as `ArrowCircuit` as in Paterson's automata; however, there
are consistency reasons \todo{explain} to opt for a further restriction: to
allow only accumulation through idempotent monoids. The combinator for doing so
is called `accumulate` and is made available through this typeclass.

The wordy comment has words roughly to the same effect, but is used, as with
every other symbol made available from this module, for Haddock documentation
(see Section\ \ref{sub:haddock}).

> -- |The class of arrows that are FRP wires.
> class (Arrow a) => ArrowWire a where
>   -- |Accumulate a value of a type that forms an idempotent monoid.
>   -- This essentially keeps a "state", initially mempty, and adds
>   -- new values that pass through, yielding the accumulated total in
>   -- the output.
>   --
>   -- The idempotent constraint is there to ensure that the output does
>   -- not change if the input does not change, which "contains" change -
>   -- an unrelated input cannot cause extra output.
>   accumulate :: (Idempotent b) => a b b

The implementation for `Wire`s of the `ArrowWire` typeclass is the only case
where we create a `WState` where there was previously none. Initially we use the
empty value from the selected monoid. A single step from an input `x` and a
previous state `x` accumulates `x` into `s` with `mappend` -- which is labelled
`s'` -- and that then forms both the output and the next state.

> instance (Arrow a) => ArrowWire (Wire a) where
>   accumulate = WState (arr process) mempty
>     where process ~(x, s) = let s' = s `mappend` x in (s', s')

\pagebreak[1]

If the underlying arrow has an instance for `ArrowZero` we make
that available as a simple lift. It would be possible to implement
this for `ArrowPlus` as well, but I did not do so due to unsubstantiated
suspicions about memory usage\todo{Think about this some more}.

> instance (ArrowZero a) => ArrowZero (Wire a) where
>   zeroArrow = WLift zeroArrow

\pagebreak[1]

The other convenience mechanisms of exposing the reader, writer,
state and error operations as typeclasses are implement here.

> instance (ArrowReader r a) => ArrowReader r (Wire a) where
>   readState = WLift readState
>   newReader (WLift x) = WLift (newReader x)
>   newReader (WState f s) = WState f' s
>     where f' = exchange ^>> newReader f
>           exchange ~((x, y), z) = ((x, z), y)

> instance (ArrowWriter w a) => ArrowWriter w (Wire a) where
>   write = WLift write
>   newWriter (WLift x) = WLift (newWriter x)
>   newWriter (WState f s) = WState (newWriter f >>^ exchange) s
>     where exchange ~((x, y), z) = ((x, z), y)

> instance (ArrowState s a) => ArrowState s (Wire a) where
>   fetch = WLift fetch
>   store = WLift store

> instance (ArrowChoice a, ArrowError ex a) => ArrowError ex (Wire a) where
>   raise = WLift raise
>   newError (WLift a) = WLift (newError a)
>   newError (WState f a) = WState f' a
>     where f' = proc ~(x, s) -> do y <- newError f -< (x, s)
>                                   case y of
>                                     Left ex  -> id -< (Left ex, s)
>                                     Right (z, s') -> id -< (Right z, s')
>   tryInUnless = tryInUnlessDefault

\pagebreak[1]
Were one to use an ImproveArrow wrapper around a `Wire`, it would be convenient
to have the `ArrowWire` instance immediately available. This is therefore
implemented.

> -- instance for ImproveArrow
> instance (ArrowWire a) => ArrowWire (ImproveArrow a) where
>   accumulate = lift accumulate

