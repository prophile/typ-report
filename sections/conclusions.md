Conclusions
===========

\label{chap:conclusions}

In this project I aimed to demonstrate a model for glitch-free functional
reactive programming in a simple model. In Chapter\ \ref{chap:glitches} I
explained what a glitch is and demonstrated that it can only arise as a result
of stuttering. I then showed how a type-level construction can enforce that one
input to an FRP network causes one and only one output, thus avoiding stuttering
and -- by extension -- glitches.

I gave a full implementation of this model using Hughes arrows in Chapter\ 
\ref{chap:impl}, including proofs for all the relevant laws in Chapter\ 
\ref{chap:proofs}. I then evaluated it against existing systems in Chapter\ 
\ref{chap:eval}.

In the forthcoming final report on this project I hope to expand much
further upon my actual implementation, including proofs for all laws
required by the various typeclasses given through equational reasoning. I
do undertake to include in that document all the details which time and
word limits have forced me to exclude from this interim report.

