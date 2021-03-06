Design
======

After a significant level of investigation into the traditional
Applicative[^1] style of FRP, I decided to follow the arrow approach
for my own implementation.  Indeed, credence has been lent to the
arrow-based approach by both Hudak\cite{arrowsRobots} and
Elliott\cite{elliottMealy}.

The standard model for arrow-based FRP is to use a stack of arrow
transformers, with either `Hask` at its base or a Kleisli arrow of
some monad, and with the Automaton transformer\cite{automatonArrows}
somewhere in the stack. `netwire` has its core type as given
in Figure\ \ref{fig:netwireType} which follows this model,
and Yampa uses a very similar mechanism for its `SF` and `SF'`
types\cite{hackage:netwire}\cite{hackage:yampa}.

[^1]: Traditional FRP uses applicative functors in no small
measure\cite{applicatives}\cite{pushPull}.

Stateful Automata
-----------------

\label{sec:stateAuto}

There is an isomorphism between Paterson's automaton
arrows\cite{automatonArrows} and existential\cite{existentialTypes}
state arrows\cite{arrowNotation}, which are shown in
Figure\ \ref{fig:existentialState} as an arrow transformer. The intuition
behind this isomorphism is that both types represent computations
which keep some state, the type of which is hidden. In the automaton
case the state is held in free variables, but existential state arrows
keep the state explicit.

The existential constraint also prevents the state from "leaking"
beyond use in further computations; as is true in the automaton
formulation.

The various instances for the existential state arrow differ from
those of ordinary state arrows as a result of the type of the state
not necessarily being the same between two values being combined.
In particular, the composition of two arrows has the product of the
two state types for state; the identity uses a unit state type[^unit].

[^unit]: The unit type (the type inhabited by one value, other than bottom) is
denoted `()` in Haskell.

\begin{figure}
\begin{lstlisting}
data EStateArrow a b c = forall s. EStateArrow s (a (b, s) (c, s))
\end{lstlisting}

\caption{Existential state arrows.}
\label{fig:existentialState}
\end{figure}

If one should choose to use the existential state arrow representation as
opposed to Paterson's automaton representation, there is one important
optimisation to make. Theoretically, a product with a unit -- for example,
composition with the identity arrow -- is identity up to isomorphism; however,
practically speaking it comes with a runtime cost[^cost].

It is convenient to have a separate constructor which can be
understood to be equivalent to the arrow with unit-state, but which
allows a more efficient representation at runtime -- in particular,
the memory does not grow for every non-stateful computation in the
network. This representation is given in
Figure\ \ref{fig:existentialStateOpt}, using GADT syntax\cite{gadts},
and it forms the foundation of my implementation, with the proofs
for the various instances given in Appendix\ \ref{apx:proofs}.

\begin{figure}
\begin{lstlisting}
data EStateArrow a b c where
  EState :: s -> a (b, s) (c, s) -> EState a b c
  ELift  :: a b c                -> EState a b c
\end{lstlisting}

\caption{Improved existential state arrows, for lower memory consumption.}
\label{fig:existentialStateOpt}
\end{figure}

[^cost]: Two machine words of memory -- 8 bytes on 32-bit platforms and 16 bytes on 64-bit -- and the cost of constructing and destructing the tuples.

Intuition
---------

The basic intuition, in summary, is that glitches arise as a result
of stuttering, which is where one input results in multiple outputs.
By including the inputs in the type of FRP reactives, it can make
the type "look like" a function: at the type level, there is no
mechanism by which a function of type $a \to b$ can return anything
other than exactly one $b$ when called with any particular $a$ as
the argument. A simple generalisation for types that "look like"
(and, in some senses, behave like) functions in Haskell is Hughes
Arrows.

