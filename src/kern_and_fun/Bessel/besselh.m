function [w,ierr] = besselh(nu,k,z,scale)
%BESSELH Bessel functions of the third kind (Hankel functions).
%	H = BESSELH(NU,K,Z), for K = 1 or 2, computes the Hankel function
%	    H1_nu(Z) or H2_nu(Z)
%	for real order NU and complex argument Z.
%	The result has size(H) = size(Z) if NU is a scalar, or
%	size(H) = [prod(size(Z)), length(NU)] if NU is a vector.
%
%	H = BESSELH(NU,Z) uses K = 1.
%	H = BESSELH(NU,1,Z,1) scales H1_nu(z) by exp(-i*z)))
%	H = BESSELH(NU,2,Z,1) scales H2_nu(z) by exp(+i*z)))
%
%	[H,IERR] = BESSELH(NU,K,Z) also returns an array of error flags.
%	    ierr = 1   Illegal arguments.
%	    ierr = 2   Overflow.  Return Inf.
%	    ierr = 3   Some loss of accuracy in argument reduction.
%	    ierr = 4   Complete loss of accuracy, z or nu too large.
%	    ierr = 5   No convergence.  Return NaN.
%
%	The relationship between the Hankel and Bessel functions is:
%
%	    besselh(nu,1,z) = besselj(nu,z) + i*bessely(nu,z)
%	    besselh(nu,2,z) = besselj(nu,z) - i*bessely(nu,z)
%
%	Example:
%
%	    This example generates the contour plot of the modulus and
%	    phase of the Hankel Function H1_0(z) shown on page 359 of
%	    Abramowitz and Stegun, "Handbook of Mathematical Functions."
%
%	    [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%	    H = besselh(0,1,X+i*Y);
%	    contour(X,Y,abs(H),0:0.2:3.2)
%	    hold on
%	    contour(X,Y,(180/pi)*angle(H),-180:10:180);
%	    prism
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

if nargin == 2
   [w,ierr] = besselmx('H',nu,k);
elseif nargin == 3
   [w,ierr] = besselmx('H'*k,nu,z);
else
   [w,ierr] = besselmx('H'*k,nu,z,scale);
end
