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
\ref{chap:impl}. I then evaluated it against existing systems in Chapter\ 
\ref{chap:eval}.

