function [w,ierr] = airy(k,z)
%AIRY	Airy functions.
%	W = AIRY(Z) is the Airy function, Ai(z), of a complex argument.
%	W = AIRY(0,Z) is the same as AIRY(Z).
%	W = AIRY(1,Z) is the derivative, Ai'(z).
%	W = AIRY(2,Z) is the Airy function of the second kind, Bi(z).
%	W = AIRY(3,Z) is the derivative, Bi'(z).
%	The argument Z may be an array and the result is the same size.
%
%	[W,IERR] = AIRY(K,Z) also returns an array of error flags.
%	    ierr = 1   Illegal arguments.
%	    ierr = 2   Overflow.  Return Inf.
%	    ierr = 3   Some loss of accuracy in argument reduction.
%	    ierr = 4   Complete loss of accuracy, z or nu too large.
%	    ierr = 5   No convergence.  Return NaN.
%
%	The relationship between the Airy and modified Bessel functions is:
%
%	    Ai(z) = 1/pi*sqrt(z/3)*K_1/3(zeta)
%	    Bi(z) = sqrt(z/3)*(I_-1/3(zeta)+I_1/3(zeta))
%	    where zeta = 2/3*z^(3/2)
%
%	This m-file uses a Fortran mex-file to call a library by D. E. Amos.
%
%	See also: BESSELJ, BESSELY, BESSELI, BESSELK.

%	Reference:
%	D. E. Amos, "A subroutine package for Bessel functions of a complex
%	argument and nonnegative order", Sandia National Laboratory Report,
%	SAND85-1018, May, 1985.
%
%	D. E. Amos, "A portable package for Bessel functions of a complex
%	argument and nonnegative order", Trans.  Math. Software, 1986.
%
%	MATLAB version: C. Moler, 3/19/94.
%	Copyright (c) 1984-94 by The MathWorks, Inc.

if nargin == 1
   [w,ierr] = besselmx('A',0,k);
elseif (k == 0) | (k == 1)
   [w,ierr] = besselmx('A',k,z);
elseif (k == 2) | (k == 3)
   [w,ierr] = besselmx('B',k-2,z);
else
   error('The first argument must be 0, 1, 2 or 3')
end
