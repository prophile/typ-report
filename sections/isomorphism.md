The State/Automaton Isomorphism
-------------------------------

The automaton arrow\cite{automatonArrows}, which corresponds to a
Mealy machine\cite{elliottMealy}, has an isomorphism to the state
arrow with an existential type for the type of the state. The types
are given in Figure \ref{fig:isoTypes}.

\begin{figure}

\begin{lstlisting}
newtype Automaton a b c = Automaton (a b (c, a b c))

data ExistentialState a b c = forall s. ExistentialState (a (s, b) (s, c)) s
\end{lstlisting}

\caption{The types of the automaton and existential state arrows.}
\label{fig:isoTypes}
\end{figure}

In essence, the automaton arrow and the state arrow do the same
job: they permit state to be kept between steps in a computation.
Whilst the ordinary state arrow makes the type of the state explicit,
the existential state arrow has the state kept implicit, hidden by
existential quantification\cite{existentialTypes}, and the initial
state is part of values of that type.

The category formed by the existential state arrow type is slightly
different to the category formed by ordinary state arrows. The exact
composition operator and identity are given in Figure
\ref{fig:estateCategory}. This uses Paterson's arrow
notation\cite{arrowNotation} for convenience. Proof of the category
laws are given in Figure \ref{fig:estateCategoryLaws}.

\begin{figure}

\begin{lstlisting}
instance (Arrow a) => Category (ExistentialState a) where
  id = ExistentialState id ()
  ExistentialState f if . ExistentialState g ig = ExistentialState h (if, ig)
    where h = proc (x, (sf, sg)) -> do (y, sg') <- g -< (x, sg)
                                       (z, sf') <- f -< (y, sf)
                                       returnA -< (z, (sf', sg'))
\end{lstlisting}

\caption{The Category instance for the existential state arrow.}
\label{fig:estateCategory}
\end{figure}

\begin{figure}

\begin{lstlisting}

-- left-identity
id . x = x
-- definition of id
ExistentialState id () . x = x
-- case analysis in x
ExistentialState id () . ExistentialState f i = ExistentialState f i
-- definition of .
ExistentialState h ((), i) = ExistentialState f i
  where h = proc (x, (sf, sg)) -> do (y, sg') <- id -< (x, sg)
                                     (z, sf') <- f -< (y, sf)
                                     returnA -< (z, (sf', sg'))
-- by parts, 1
((), i) = i
-- true by trivial isomorphism

-- by parts, 2
h = f
  where h = proc (x, (sf, sg)) -> do (y, sg') <- id -< (x, sg)
                                     (z, sf') <- f -< (y, sf)
                                     returnA -< (z, (sf', sg'))
-- by identity in the underlying arrow
h = f
  where h = proc (x, (sf, sg)) -> do (z, sf') <- f -< (x, sf)
                                     returnA -< (z, (sf', sg))
-- case analysis in sf
h = f
  where h = proc (x, ((), sg)) -> do (z, sg') <- f -< (x, sg)
                                     returnA -< (z, ((), sg'))
-- by isomorphism between ((), x) and x
h = f
  where h = proc (x, sg) -> do (z, sg') <- f -< (x, sg)
                               returnA -< (z, sg')
-- by identity in the underlying arrow
h = f
  where h = proc (x, sg) -> f -< (x, sg)
-- by expansion of arrow notation
h = f
  where h = f
-- substitution
f = f


-- right-identity
x . id = x
-- definition of id
x . ExistentialState id () = x
-- case analysis in x
ExistentialState f i . ExistentialState id () = ExistentialState f i
-- definition of .
ExistentialState h (i, ()) = ExistentialState f i
  where h = proc (x, (sf, sg)) -> do (y, sg') 
-- by parts, 1
(i, ()) = i
-- true by trivial isomorphism

-- by parts, 2


\end{lstlisting}

\caption{Proofs of the category laws for the existential state arrow.}
\label{fig:estateCategoryLaws}
\end{figure}

