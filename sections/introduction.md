Introduction
============

Event-driven programming is a useful paradigm for interactive
systems, contrasting sharply with the single-run traditional model
of computation.  However, most current programming systems still
follow the traditional model quite closely, making them unwieldy
for interactive use. Reactive programming is a paradigm in which
dependent variables change value relative to their dependencies.
To give a concrete example, consider the code in Figure\
\ref{fig:rpBasicExample}.

\begin{figure}[h]

\begin{lstlisting}
a := 10
b := 20
c := a + b
b := -10
print c
\end{lstlisting}

\caption{A simple code block with differing output using imperative and reactive
semantics.}
\label{fig:rpBasicExample}
\end{figure}

Under the normal imperative model of computation, this would print the value
`30`. In the reactive programming model, `c` *reacts* to the change in `b`, and
this program prints the value `0`.

The reactive model of computation can be seen in spreadsheet systems,
where changing the value in an input cell causes a corresponding
change in in an output cell. Functional reactive programming is an
attempt to capture the reactive paradigm using current functional
techniques. It has been successfully used in a range of programming
languages including C#, JavaScript, and Elm.

Many\todo{cite} current functional reactive programming implementations suffer from a
problem of stuttering, in which a single input can cause multiple outputs. Some
of these outputs may, in certain circumstances, be erroneous. I
will cover this in much more detail in Chapter\ \ref{chap:glitches}, but a brief
explanation is in order.

Consider the triangular graph of dependencies given in
Figure\ \ref{fig:exampleDeps}. In this graph, we shall assume that
we are dealing with booleans. Let `B` depend on `A`, being its
negation, and let `C` depend both on `A` and `B`, being their
conjunction. It seems that at any point in time, the value held in
`C` is $\bot$, being essentially $A \land \lnot A$.

If we use a semantics where changes in a value are "pushed" to any
dependent value, `C` can receive an update from `A` through *both* paths,
and thus 'stutter', or produce more than one output for a single change in
input. The danger here is the order in which updates occur. If a change
from $\bot$ to $\top$ takes place in `A` and is "pushed" into `C` before
`B`, `C` "sees" $\top$ from both `A` *and* `B`, and this erroneously gives
the output $\top$ until the update is received from the other path.

Using Haskell, I will show how using FRP formulations that, in
contrast to some, capture both inputs and outputs can be shown to
produce exactly one output for every input, enforced at the type
level. This prevents stuttering, and in so doing prevents glitches.

\begin{figure}
\centering
\digraph{Layout}{A -> C; A -> B; B -> C}
\caption{A triangular graph. The nodes represent functional reactive
`behaviours', and the edges represent dependencies.}
\label{fig:exampleDeps}
\end{figure}

