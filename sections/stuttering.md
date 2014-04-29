Stuttering and Glitches
=======================

\label{chap:glitches}

Many FRP systems suffer from a problem of glitches. They can arise as a result
of simultaneous changes in inputs. Imagine a behaviour `A` dependent on two
other behaviours `B` and `C`, which just takes their sum. Any change in either
`B` or `C` should cause a corresponding change in `A` since that is the essence
of reactive programming.

The most obvious semantics of this, and the semantics Elliott
gives\cite{pushPull}, is that behaviours are time functions. At
some particular interval, the outputs are evaluated, which will in
turn evaluate the behaviours upon which they depend.  This is known
as the "pull" semantics, where values at a particular time are
"pulled" through the network from the outputs.

An alternative, and more widely used, system is the "push" semantics. Under the
push semantics, changes in the inputs of a network are propagated through. This
is usually much more efficient for interactive systems because computation only
happens when made necessary by a change in the environment, and thus a change in
the inputs.

Returning to our previous example, the push semantics breaks everything in a
number of cases, the simplest of which is the case where `B` and `C` are the
same value. A new value of `B` is pushed into `A`, but the other input needs to
be pushed simultaneously: otherwise, `a` takes a sum, transiently, from a stale
input on one side. It is not an unreasonable assumption that if `A` is `B + B`
then it is equivalent to `2 * B` by the basic laws of arithmetic. In the
presence of stuttering, this is not the case.

Perhaps even more egregious is the example I gave in the introduction:
of $A \land \lnot A$ being $\top$, by the same mechanism. Imagine
that being used, for instance, in a safety-critical system: to draw
on a standard Haskell example\cite{beautiful}, the missiles would
be fired\cite{hackage:acme-missiles}. It is entirely reasonable for
a programmer to expect that $A \land \lnot A$ can never occur, as a
matter of basic logic -- it would be an edge case nobody would be
likely to account for[^digilog].

[^digilog]: It is worth noting that a similar problem _can_ occur in digital
logic circuits, although via an entirely different
mechanism\cite{digitalHazards}.

One possible solution here is to have each node "wait" on each of its inputs in
turn, only yielding a value each time it has received an update from every
input. This removes the stuttering entirely and therefore glitches. This makes
the network equivalent to a Kahn process network\cite{kahn}. However, a problem
arises on a network which has multiple inputs overall: only after each input to
the network has arrived does a change in the output occur. As an example,
consider a network which takes inputs from two sensors and sums them. A
detection event on one sensor would not be enough on its own to trigger a change
in the network's output, making the state of the output inconsistent with the
state of the inputs.

One can also imagine a system of substructural types\cite{substructural}
-- probably either linear\cite{linearTypes} or affine -- which
prevent a single input to the network being combined with itself.
While this is appealing it is also difficult to implement in languages
which lack linear types in the first place\cite{linearityAndLaziness}
and such combinations can be useful in practice. Still, it is
possible that further research might be done on the use of linear
or affine types in this circumstances, perhaps in a language with
language-level support for linear types such as `Clean`\cite{cleanIO}
or Rust\cite{lang:rust}.
