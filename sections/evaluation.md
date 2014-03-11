Evaluation
==========

\label{chap:eval}

Comparison with Netwire
-----------------------

The AFRP package `netwire` has as its core type the type given in Figure\ 
\ref{fig:netwireType}\cite{hackage:netwire}[^others]. `e` is the error type for
propagation of errors through the wire; for simplicity let us assume an
error-free environment where `e` is `Void`, which removes the `Either`s from
scope. Netwire's `Wire s m a b` then becomes `ReaderArrow s (Automaton (Kleisli
m))`. Given the isomorphism between `Automaton` and the `Wire` type I
implemented in Chapter\ \ref{chap:impl} (described in Section\ 
\ref{sec:stateAuto}), my implementation can be seen as a generalisation of
`netwire` since `netwire`'s wires can be constructed with arrow transformers and
using the Kleisli arrow of the underlying monad parameter `m` as a basis.

The `s` parameter is the type of times.

\begin{figure}
\begin{lstlisting}
data Wire s e m a b = WGen (s -> Either e a -> m (Either e b, Wire s e m a b))
-> Wire s e m a b
\end{lstlisting}

\caption{Netwire's \texttt{Wire} type.}
\label{fig:netwireType}
\end{figure}

[^others]: It also has a collection of other constructors which are simplified
variants for optimisation purposes, but they can all be reduced to that form via
the `stepWire` function.

