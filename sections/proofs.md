Proofs
======

\label{chap:proofs}

\todo{Fix all the Markdown/LaTeX wackiness in the captions.}

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
is shown in Figure\ \ref{fig:proofCategoryAssoc} and relies on the isomorphism
given in Figure\ \ref{fig:isoUnitState}\todo{Write out the isomorphism}, giving
only the `WState` case without loss of generality\todo{Prove associativity}.

\begin{figure}
\begin{lstlisting}
\end{lstlisting}

\caption{Isomorphism between WLift and WState with unit state.}
\label{fig:isoUnitState}
\end{figure}

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
-- using the WLift to unit WState isomorphism
WState f fs . (WState g gs . WState h hs) = (WState f fs . WState g gs) . WState
h hs
\end{lstlisting}

\caption{Proof of the associativity law for `Wire a`.}
\label{fig:proofCategoryAssoc}
\end{figure}

Arrow
-----

When `a` is an arrow, `Wire a` forms an arrow, with the instance given in
Figure\ \ref{fig:proofArrowInstance}. The seven arrow laws are proven respectively in
Figures\ \ref{fig:proofArrow1}, \ref{fig:proofArrow2}, \ref{fig:proofArrow3},
\ref{fig:proofArrow4}\todo{Complete this proof}, \ref{fig:proofArrow5}\todo{Complete this proof}, \ref{fig:proofArrow6}, and
\ref{fig:proofArrow7}.

\begin{figure}
\begin{lstlisting}
instance (Arrow a) => Arrow (Wire a) where
  arr = WLift . arr
  first (WLift f) = WLift (first f)
  first (WState f s) = WState (exchange ^>> first f >>^ exchange) s
    where exchange ~((x, y), z) = ((x, z), y)
\end{lstlisting}

\caption{The `Arrow` instance for `Wire a`.}
\label{fig:proofArrowInstance}
\end{figure}

\begin{figure}
\begin{lstlisting}
arr id = id
-- definition of id
arr id = WLift id
-- definition of arr
(WLift . arr) id = WLift id
-- expansion of composition
WLift (arr id) = WLift id
-- arr id = id in a
WLift id = WLift id
\end{lstlisting}

\caption{The first arrow law.}
\label{fig:proofArrow1}
\end{figure}

\begin{figure}
\begin{lstlisting}
arr (f >>> g) = arr f >>> arr g
-- definition of (>>>)
arr (g . f) = arr g . arr f
-- definition of arr
(WLift . arr) (g . f) = (WLift . arr) g . (WLift . arr) f
-- expansion of composition
WLift (arr (g . f)) = WLift (arr g) . WLift (arr f)
-- definition of (.)
WLift (arr (g . f)) = WLift (arr g . arr f)
-- definition of (>>>)
WLift (arr (f >>> g)) = WLift (arr f >>> arr g)
-- arr (f >>> g) = arr f >>> arr g in a
WLift (arr f >>> arr g) = WLift (arr f >>> arr g)
\end{lstlisting}

\caption{The second arrow law.}
\label{fig:proofArrow2}
\end{figure}

\begin{figure}
\begin{lstlisting}
first (arr f) = arr (first f)
-- definition of arr
first ((WLift . arr) f) = (WLift . arr) (first f)
-- expansion of composition
first (WLift (arr f)) = WLift (arr (first f))
-- definition of first
WLift (first (arr f)) = WLift (arr (first f))
-- first (arr f) = arr (first f) in a
WLift (arr (first f)) = WLift (arr (first f))
\end{lstlisting}

\caption{The third arrow law.}
\label{fig:proofArrow3}
\end{figure}

\begin{figure}
\begin{lstlisting}
first (f >>> g) = first f >>> first g
-- definition of (>>>)
first (g . f) = first g . first f
-- case analysis in g, f
first (WState f fs . WState g gs) = first (WState f fs) . first (WState g fs)
-- definition of first
first (WState f fs . WState g gs) = WState (exchange ^>> first f >>^ exchange) fs . WState (exchange ^>> first g >>^ exchange) gs
  where exchange ~((x, y), z) = ((x, z), y)
\end{lstlisting}

\caption{The fourth arrow law, relying on the isomorphism from
Figure~\ref{fig:isoUnitState}.}
\label{fig:proofArrow4}
\end{figure}

\begin{figure}
\begin{lstlisting}
first f >>> arr fst = arr fst >>> f
-- definition of (>>>)
arr fst . first f = f . arr fst
-- expansion of f
arr fst . first (WState f fs) = WState f fs . arr fst
-- definition of arr
(WLift . arr) fst . first (WState f fs) = WState f fs . (WLift . arr) fst
-- expansion of composition
WLift (arr fst) . first (WState f fs) = WState f fs . WLift (arr fst)
-- definition of first
WLift (arr fst) . WState (exchange ^>> first f >>^ exchange) fs = WState f fs . WLift (arr fst)
-- definition of (.)
WState (first (arr fst) . (exchange ^>> first f >>^ exchange)) fs = WState f fs . WLift (arr fst)
-- definitions of (^>>) and (>>^)
WState (first (arr fst) . arr exchange . first f . arr exchange) fs = WState f fs . WLift (arr fst)
-- first (arr f) = arr (first f) in a
WState (arr (first fst) . arr exchange . first f . arr exchange) fs = WState f fs . WLift (arr fst)
-- arr f . arr g = arr (f . g) in a
WState (arr (first fst . exchange) . first f . arr exchange) fs = WState f fs . WLift (arr fst)
\end{lstlisting}

\caption{The fifth arrow law, relying on the isomorphism from Figure~\ref{fig:isoUnitState}.}
\label{fig:proofArrow5}
\end{figure}

\begin{figure}
\begin{lstlisting}
first f >>> arr (id *** g) = arr (id *** g) >>> first f
\end{lstlisting}

\caption{The sixth arrow law.}
\label{fig:proofArrow6}
\end{figure}

\begin{figure}
\begin{lstlisting}
first (first f) >>> arr assoc = arr assoc >>> first f
\end{lstlisting}

\caption{The seventh arrow law.}
\label{fig:proofArrow7}
\end{figure}

