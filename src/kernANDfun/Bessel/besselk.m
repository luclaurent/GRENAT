function [w,ierr] = besselk(nu,z,scale)
%BESSELK Modified Bessel functions of the second kind.
%	K = BESSELK(NU,Z) computes modified Bessel functions of the second kind
%	    K_nu(Z)
%	for real order NU and complex argument Z.
%	The result has size(K) = size(Z) if NU is a scalar, or
%	size(K) = [prod(size(Z)), length(NU)] if NU is a vector.
%
%	K = BESSELK(NU,Z,1) scales K_nu(z) by exp(-abs(real(z)))
%
%	[K,IERR] = BESSELK(NU,Z) also returns an array of error flags.
%	    ierr = 1   Illegal arguments.
%	    ierr = 2   Overflow.  Return Inf.
%	    ierr = 3   Some loss of accuracy in argument reduction.
%	    ierr = 4   Complete loss of accuracy, z or nu too large.
%	    ierr = 5   No convergence.  Return NaN.
%
%	Example:
%
%	    besselk(3:9,[0:.2:9.8 10:.5:20],1) generates the entire 
%	    71-by-7 table on page 424 of Abramowitz and Stegun,
%	    "Handbook of Mathematical Functions."
%
%	This m-file uses a Fortran mex-file to call a library by D. E. Amos.
%
%	See also: BESSELJ, BESSELY, BESSELI.

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
   [w,ierr] = besselmx('K',nu,z);
else
   [w,ierr] = besselmx('K',nu,z,scale);
end
