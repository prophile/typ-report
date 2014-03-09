Introduction
============

Event-driven programming is a useful paradigm for interactive systems,
contrasting sharply with the single-run traditional model of computation.
However, most current programming systems still follow the traditional model
quite closely, making them unwieldy for interactive use.

Reactive programming is a programming paradigm in which dependent variables
change value relative to their dependencies. To give a concrete example,
consider the code in Figure \ref{fig:rpBasicExample}.

\begin{figure}

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

The reactive model of computation can be seen in spreadsheet systems, where
changing an input cell causes a corresponding change in in an output cell.

Functional reactive programming is an attempt to capture the reactive paradigm
using current functional techniques. It has been successfully used in a range of
programming languages including C#, JavaScript, and Elm.

Many current functional reactive programming implementations suffer from a
problem of stuttering, in which a single input can cause multiple outputs. Some
of these outputs may, in certain circumstances, be erroneous.

Using Haskell, I will show how using a FRP formulation that, in contrast to
some, captures both inputs and outputs can be shown to produce exactly one
output for every input with enforcement at the type level.

\begin{equation}
\textbf{React}(A,B) = (B \times \textbf{React}(A, B))^A
\label{eqn:frp}
\end{equation}

