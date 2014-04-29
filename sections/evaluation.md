Evaluation
==========

\label{chap:eval}

Comparison with Netwire
-----------------------

The AFRP package `netwire` has as its core type the type given in
Figure\ \ref{fig:netwireType}\cite{hackage:netwire}, modulo its
extra constructors. `e` is the error type for propagation of errors
through the wire; for simplicity let us assume an error-free
environment where `e` is `Void`, which removes the `Either`s from
scope. Netwire's `Wire s m a b` then becomes `ReaderArrow s (Automaton
(Kleisli m))`. Given the isomorphism between `Automaton` and the
`Wire` type I implemented in Chapter\ \ref{chap:impl} (described
in Section\ \ref{sec:stateAuto}), my implementation can be seen as
a generalisation of `netwire` since `netwire`'s wires can be
constructed with arrow transformers and using the Kleisli arrow of
the underlying monad parameter `m` as a basis.

The `s` parameter is the type of times.

\begin{figure}
\begin{lstlisting}
data Wire s e m a b = WGen (s -> Either e a -> m (Either e b, Wire s e m a b))
-> Wire s e m a b
\end{lstlisting}

\caption{Netwire's \texttt{Wire} type.}
\label{fig:netwireType}
\end{figure}

The extra constructors are important, however. `netwire` has five
different constructors for its wire type, in order to avoid using more
memory than necessary for its various operations: the `Wire` type I
present does the same job with a mere two constructors.

[^others]: It also has a collection of other constructors which are simplified
variants for optimisation purposes, but they can all be reduced to that form via
the `stepWire` function.

bacon.js
--------

`bacon.js`\cite{ws:bacon} is an FRP system for JavaScript. It is
very much designed from a standpoint of pragmatism rather than
purity. `bacon.js` is formulated around the classic FRP approach
of signals and behaviours, to which it gives the names `EventStream`
and `Property`. It also abstracts their both being subtypes of an
over-arching `Observable` type.

`bacon.js` has had a glitch-avoidance mechanism with its `Properties` since
version 0.7\cite{ws:bacon:relnotes}, constructed by means of building a
dependency tree for dispatch\cite{ws:bacon:glitchFree}.

Classic FRP
-----------

One of Elliott's stated goals with functional reactive programming was to
introduce an abstraction where one can work with continuous time. Obviously,
discrete FRP does not fulfil that abstraction, though the possibility of push
semantics makes it much more efficient\cite{pushPull}. Elliott tried to resolve
this difference in the Push-Pull FRP paper.

While glitches can be mitigated against in the classic FRP formulation,
as demonstrated in the case of `bacon.js`, it seems (after months
of trying) it is not possible to give a sensible semantics under
which they can be avoided in general. In the `bacon.js` case the
dispatch mechanism comes at the cost of significant potential
inconsistencies in order to use a reasonable amount of
memory\cite{ws:bacon:incon}.

