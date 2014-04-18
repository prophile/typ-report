Annotated Source
----------------

For the sake of completeness, I include here the entire annotated source for the
wire arrow transformer.

The `Wire` type uses existential types. For the sake of simplicity, we pull in
the full language extension for generalized algebraic data types\cite{gadts}.

> {-# LANGUAGE GADTs #-}

Again for the sake of simplicity, rather than writing out arrow combinators in
full, we pull in the language extension for Paterson's arrow
notation\cite{arrowNotation}.

> {-# LANGUAGE Arrows #-}

The `ArrowWriter`, `ArrowReader` and `ArrowState` instance need the flexible
instance language features, so we pull those in too.

> {-# LANGUAGE FlexibleInstances #-}
> {-# LANGUAGE MultiParamTypeClasses #-}
> {-# LANGUAGE UndecidableInstances #-}

From the module, we export the main `Wire` type:

> -- |Very simple FRP state wires.
> module Control.FRP.Wire(Wire,

Accumulation belongs in a typeclass, so we export the class and the one function
it contains.

>                         ArrowWire,
>                         accumulate,

To "remove the transformer" we have the `stepWire` function, and as a matter of
convenience we also have `runWire`.

>                         runWire,
>                         stepWire) where

The `id` and `.` definitions from `Prelude` are specialised to `Hask` rather
than general categories, so we hide those so we can take the generalised
versions from `Control.Category`.

> import Prelude hiding (id, (.))
>
> import Control.Category

The core of the arrow combinator library is in `Control.Arrow` (other than the
category typeclass) so we import that too.

> import Control.Arrow

From Paterson's `arrows` package we also import the arrow transformer mechanism
and the typeclasses.

> import Control.Arrow.Transformer
> import Control.Arrow.Operations

Since accumulation works on idempotent monoids, we need both the `Data.Monoid`
module from `base` and the `Data.Monoid.Idempotent` module from the `idempotent`
package described in Section\ \ref{sec:idempotent}.

> import Data.Monoid
> import Data.Monoid.Idempotent

Since arrows can be improved with the mechanism from the `arrow-improve` package
described in Section\ \ref{sec:improve}, we also export later an instance for
the `ArrowWire` typeclass for improved arrows.

> import Control.Arrow.Improve

> -- |The Wire transformer, transforming an arrow a to a wire on that arrow.
> data Wire a b c where
>   WLift :: a b c -> Wire a b c
>   WState :: a (b, s) (c, s) -> s -> Wire a b c

> -- |Run an IO-free wire, running indefinitely.
> runWire :: (Arrow a) => Wire a () () -> a () ()
> runWire (WLift a) = ioLoop
>   where ioLoop = a >>> ioLoop
> runWire (WState f s) = const ((), s) ^>> ioLoop >>^ const ()
>   where ioLoop = f >>> ioLoop

> -- |Run a single step of a wire, essentially transforming the Wire into an
> -- automaton.
> stepWire :: (Arrow a) => Wire a b c -> a b (c, Wire a b c)
> stepWire w@(WLift a) = a >>^ (\x -> (x, w))
> stepWire (WState f s) = (\x -> (x, s)) ^>> f >>^ (\(x, s') -> (x, WState f s'))

> instance (Arrow a) => Category (Wire a) where
>   id = WLift id
>   WLift f . WLift g = WLift (f . g)
>   WLift f . WState g isg = WState (first f . g) isg
>   WState f isf . WLift g = WState (f . first g) isf
>   WState f isf . WState g isg = WState h (isf, isg)
>     where h = proc ~(x, (sf, sg)) -> do ~(y, sg') <- g -< (x, sg)
>                                         ~(z, sf') <- f -< (y, sf)
>                                         id -< (z, (sf', sg'))

> instance (Arrow a) => Arrow (Wire a) where
>   arr = WLift . arr
>   first (WLift f) = WLift (first f)
>   first (WState f s) = WState (exchange ^>> first f >>^ exchange) s
>     where exchange ~((x, y), z) = ((x, z), y)

> instance (ArrowChoice a) => ArrowChoice (Wire a) where
>   left (WLift f) = WLift (left f)
>   left (WState f s) = WState (exchange ^>> left f >>^ unexchange) s
>     where exchange (Left x, y) = Left (x, y)
>           exchange (Right x, y) = Right (x, y)
>           unexchange (Left (x, y)) = (Left x, y)
>           unexchange (Right (x, y)) = (Right x, y)

> instance (ArrowLoop a) => ArrowLoop (Wire a) where
>   loop (WLift f) = WLift (loop f)
>   loop (WState f s) = WState (loop $ exchange ^>> f >>^ exchange) s
>     where exchange ~((a, b), c) = ((a, c), b)

> instance (Arrow a) => ArrowTransformer Wire a where
>   lift = WLift

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

> instance (Arrow a) => ArrowWire (Wire a) where
>   accumulate = WState (arr process) mempty
>     where process ~(x, s) = let s' = s `mappend` x in (s', s')

> instance (ArrowZero a) => ArrowZero (Wire a) where
>   zeroArrow = WLift zeroArrow

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

> -- instance for ImproveArrow
> instance (ArrowWire a) => ArrowWire (ImproveArrow a) where
>   accumulate = lift accumulate

