function [w,ierr] = bessely(nu,z,scale)
%BESSELY Bessel functions of the second kind.
%	Y = BESSELY(NU,Z) computes Bessel functions of the second kind
%	    Y_nu(Z)
%	for real order NU and complex argument Z.
%	The result has size(Y) = size(Z) if NU is a scalar, or
%	size(Y) = [prod(size(Z)), length(NU)] if NU is a vector.
%
%	Y = BESSELY(NU,Z,1) scales Y_nu(z) by exp(-abs(imag(z)))
%
%	[Y,IERR] = BESSELY(NU,Z) also returns an array of error flags.
%	    ierr = 1   Illegal arguments.
%	    ierr = 2   Overflow.  Return Inf.
%	    ierr = 3   Some loss of accuracy in argument reduction.
%	    ierr = 4   Complete loss of accuracy, z or nu too large.
%	    ierr = 5   No convergence.  Return NaN.
%
%	Example:
%
%	    bessely(3:9,(10:.2:20)') generates the 51-by-7 table on page 401
%	    of Abramowitz and Stegun, "Handbook of Mathematical Functions."
%
%	This m-file uses a Fortran mex-file to call a library by D. E. Amos.
%
%	See also: BESSELJ, BESSELI, BESSELK, BESSELH.

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

if nargin == 2
   [w,ierr] = besselmx('Y',nu,z);
else
   [w,ierr] = besselmx('Y',nu,z,scale);
end
