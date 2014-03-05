Implementation
==============

\todo{Organise this section}

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

Certain arrows are relatively heavyweight. This often stretches to arrows which
are created from the `arr` and `id` functions both of which could be expected to
be cheap, and certainly one imagines that they could be folded together.

Additionally, there are a number of typeclasses that all arrows satisfy, but
which it is tedious to enumerate for every arrow implemented -- `Functor`,
`Profunctor`, `Strong` and `Applicative` for all arrows as well as
`Alternative` (and `Monoid`, following the precedent set by Paterson in the
`arrows` package) for arrows satisfying `ArrowPlus`, `Choice` for arrows
satisfying `ArrowChoice`, and others.

I introduced an arrow wrapper, `ImproveArrow`, which wraps any existing arrow
while providing cheap `arr` and `id` which are necessarily fused, and providing
the set of instances mentioned above. As with the idempotent package, this was
then published on Hackage\cite{hackage:arrow-improve}.

