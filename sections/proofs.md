Proofs
======

\label{chap:proofs}

As described in Chapter\ \ref{chap:impl}, the core data type is given in
Figure\ \ref{fig:coredataProofs}.

\begin{figure}
\begin{lstlisting}
data Wire a b c where
  WLift :: a b c -> Wire a b c
  WState :: a (b, s) (c, s) -> s -> Wire a b c
\end{lstlisting}

\caption{The core state-wire data type.}
\label{fig:coredataProofs}
\end{figure}

Category
--------

When `a` is an `Arrow`, `Wire a` forms a category, with the instance given in
Figure\ \ref{fig:proofCategoryInstance}. The left-identity law is shown in
Figure\ \ref{fig:proofCategoryLeftId}. The right-identity law is shown in
Figure\ \ref{fig:proofCategoryRightId}. Both the left- and right- identity laws
rely on the lemma given in Figure\ \ref{fig:firstLemma}. The associativity law
is shown in Figure\ \ref{fig:proofCategoryAssoc}.

\begin{figure}
\begin{lstlisting}
first id = id
-- id = arr id (arrow law)
first (arr id) = arr id
-- first (arr f) = arr (first f) (arrow law)
arr (first id) = arr id
-- definition of first for functions
arr (id *** id) = arr id
-- definition of *** for functions
arr (\(x, y) -> (id x, id y)) = arr id
-- id x = x
arr (\(x, y) -> (x, y)) = arr id
-- trivial identity
arr id = arr id
\end{lstlisting}
\caption{Lemma: `first id = id`}.
\label{fig:firstLemma}
\end{figure}

\begin{figure}
\begin{lstlisting}
instance (Arrow a) => Category (Wire a) where
  id = WLift id
  WLift f . WLift g = WLift (f . g)
  WLift f . WState g isg = WState (first f . g) isg
  WState f isf . WLift g = WState (f . first g) isf
  WState f isf . WState g isg = WState h (isf, isg)
    where h = proc ~(x, (sf, sg)) -> do ~(y, sg') <- g -< (x, sg)
                                        ~(z, sf') <- f -< (y, sf)
                                        id -< (z, (sf', sg'))
\end{lstlisting}

\caption{The `Category` instance for `Wire a`.}
\label{fig:proofCategoryInstance}
\end{figure}

\begin{figure}
\begin{lstlisting}
id . f = f
-- substitute definition of id
WLift id . f = f
-- case analysis in f

-- CASE 1: f = WLift g
WLift id . WLift g = WLift g
-- definition of (.)
WLift (id . g) = WLift g
-- left-identity of (.) for a
WLift g = WLift g

-- CASE 2: f = WState g s
WLift id . WState g s = WState g s
-- definition of (.)
WState (first id . g) s = WState g s
-- first id = id
WState (id . g) s = WState g s
-- left-identity of (.) for a
WState g s = WState g s
\end{lstlisting}

\caption{Proof of the left-identity law for `Wire a`.}
\label{fig:proofCategoryLeftId}
\end{figure}

\begin{figure}
\begin{lstlisting}
f . id = f
-- substitute definition of id
f . WLift id = f
-- case analysis in f

-- CASE 1: f = WLift g
WLift g . WLift id = WLift g
-- definition of (.)
WLift (g . id) = WLift g
-- right-identity of (.) for a
WLift g = WLift g

-- CASE 2: f = WState g s
WState g s . WLift id = WState g s
-- definition of (.)
WState (g . first id) s = WState g s
-- first id = id
WState (g . id) s = WState g s
-- right-identity of (.) for a
WState g s = WState g s

\end{lstlisting}

\caption{Proof of the right-identity law for `Wire a`.}
\label{fig:proofCategoryRightId}
\end{figure}

\begin{figure}
\begin{lstlisting}
f . (g . h) = (f . g) . h
\end{lstlisting}

\caption{Proof of the associativity law for `Wire a`.}
\label{fig:proofCategoryAssoc}
\end{figure}

