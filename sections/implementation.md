Implementation
==============

\label{chap:impl}

\todo{Organise this section}

Most of the operations of the Wire type are the operations of the basic arrow
typeclasses. Wire is also an arrow transformer and an instance of the
`ArrowCircuit` typeclass\cite{automatonArrows}.

Idempotent
----------

For consistency as mentioned elsewhere\todo{explain where} in this report,
accumulation needs not just monoids on values, but idempotent monoids. There is
no typeclass for idempotent monoids anywhere within Haskell's standard
libraries[^1].

[^1]: That is to say, libraries included with GHC or the Haskell platform.

As a result, I wrote the typeclass as well as its common instances and factored
them out to a separate library, which then was published on Haskell's package
index, Hackage\cite{hackage:idempotent}.

Improving Arrows
----------------

Certain arrows are relatively heavyweight. This often stretches to
arrows which are created from the `arr` and `id` functions both of
which could be expected to be cheap, and certainly one might imagine
that they could be folded together.

Additionally, there are a number of typeclasses that all arrows
satisfy, but which it is tedious to enumerate for every arrow
implemented -- `Functor`, `Profunctor`\cite{hackage:profunctors},
`Strong` and `Applicative`\cite{applicatives} for all arrows as
well as `Alternative` (and `Monoid`, following the precedent set
by Paterson in the `arrows` package\cite{hackage:arrows}) for arrows
satisfying `ArrowPlus`, `Choice` for arrows satisfying `ArrowChoice`,
and others.

I introduced an arrow wrapper, `ImproveArrow`, which wraps any
existing arrow while providing cheap `arr` and `id` which are
necessarily fused, and providing the set of instances mentioned
above. As with the idempotent package, this was then published on
Hackage\cite{hackage:arrow-improve}. It is in some ways analogous
to the `CoYoneda`\cite{hackage:kan-extensions} type as it applies
to Functors, in that it folds mappings into single functions, albeit
mappings via composition and `arr` rather than `fmap`.
