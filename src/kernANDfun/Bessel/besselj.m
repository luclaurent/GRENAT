function [w,ierr] = besselj(nu,z,scale)
%BESSELJ Bessel functions of the first kind.
%	J = BESSELJ(NU,Z) computes Bessel functions of the first kind
%	    J_nu(Z)
%	for real order NU and complex argument Z.
%	The result has size(J) = size(Z) if NU is a scalar, or
%	size(J) = [prod(size(Z)), length(NU)] if NU is a vector.
%
%	J = BESSELJ(NU,Z,1) scales J_nu(z) by exp(-abs(imag(z)))
%
%	[J,IERR] = BESSELJ(NU,Z) also returns an array of error flags.
%	    ierr = 1   Illegal arguments.
%	    ierr = 2   Overflow.  Return Inf.
%	    ierr = 3   Some loss of accuracy in argument reduction.
%	    ierr = 4   Complete loss of accuracy, z or nu too large.
%	    ierr = 5   No convergence.  Return NaN.
%
%	Examples:
%
%	    besselj(3:9,(10:.2:20)') generates the 51-by-7 table on page 400
%	    of Abramowitz and Stegun, "Handbook of Mathematical Functions."
%
%	    besselj(2/3:1:98/3,r) generates the fractional order Bessel
%	    functions used by the MathWorks Logo, the L-shaped membrane.
%	    J_2/3(r) matches the singularity at the interior corner
%	    where the angle is pi/(2/3).
%
%	This m-file uses a Fortran mex-file to call a library by D. E. Amos.
%
%	See also: BESSELY, BESSELI, BESSELK, BESSELH.

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
   [w,ierr] = besselmx('J',nu,z);
else
   [w,ierr] = besselmx('J',nu,z,scale);
end
