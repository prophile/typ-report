Stuttering and Glitches
=======================

Simple FRP systems suffer from a problem called glitches. Consider, under the
usual Applicative interpretation, the example given in Figure
\ref{fig:glitchExample}.

\begin{figure}

\begin{lstlisting}
input :: Reactive Bool

output :: Reactive Bool
output = liftA2 (&&) input (fmap not input)
\end{lstlisting}

\caption{An example of a glitch.}
\label{fig:glitchExample}
\end{figure}

Under the pull semantics, one can observe that `output` must necessarily take
the value `False`, since in normal logic the conjunction of any value with its
negation is false.

Under the push semantics, however, one can potentially witness a very surprising
result, depending on the push-order. Assuming push is left-biased (that is,
`<*>` receives updates from its left argument first), consider the case in which
`input` has an edge from `False` to `True`. In this case, `output` receives an
update taking its first input from `False` to `True` -- and using the previous
value of the other output, it evaluates `True && True` as `True` before the
update on the right-hand input is received.

This is somewhat unfortunate. It is similar, in many ways, to an analogous
problem arising from propagation delays in digital logic
circuits\cite{digitalHazards}.

A critical observation here is that glitches arise as part of a larger
phenomenon which we will call "stuttering": informally, the case where a single
change in a network's input will cause more than one change in a network's
output. While glitches may be avoided in other ways, a transient error cannot
occur if transients cannot occur at all -- in other words, removing the problem
of stuttering prevents, by definition, the emergence of glitches.

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

One can also imagine a system of substructural types -- probably either linear
or affine -- which prevent a single input to the network being combined with
itself. While this is appealing it is also difficult to implement in languages
which lack linear types in the first place and such combinations can be useful
in practice. Still, it is possible that further research might be done on the
use of linear or affine types in this circumstances, perhaps in a language with
language-level support for linear types such as `Clean`.

