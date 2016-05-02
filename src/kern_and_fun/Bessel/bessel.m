function [w,ierr] = bessel(nu,z)
%BESSEL	Bessel functions of various kinds.
%	The suite of M-files for Bessel functions has been modified and
%	extended twice since the reference manuals for MATLAB 4.0 were
%	printed.  The most recent version uses Fortran Mex files to access
%	a library written by D. E. Amos.  Bessel functions of complex
%	argument are now fully supported.
%
%	The primary functions in the suite are:
%
%	    BESSELJ(NU,Z)    Bessel functions of the first kind,
%	    BESSELY(NU,Z)    Bessel functions of the second kind,
%	    BESSELI(NU,Z)    Modified Bessel functions of the first kind,
%	    BESSELK(NU,Z)    Modified Bessel functions of the second kind,
%	    BESSELH(NU,K,Z)  Hankel functions,
%	    AIRY(K,Z)        Airy functions.
%
%	Two old functions, BESSELA and BESSELN, are now obsolete.
%	This M-file, BESSEL(NU,X), simply calls BESSELJ(NU,X).

%	The Bessel suite is distributed via anonymous FTP from
%	    ftp.mathworks.com
%	and is available on disc in Unix tar, DOS, or Mac format from
%	MathWorks Technical Support (support@mathworks.com).
%
%	Several files are available:
%	    bessel.readme   -- This file.
%	    bessel.m        -- This file.
%	    bessel?.m       -- Five M-files for the five Bessel functions.
%	    airy.m          -- One M-file for the Airy function.
%	    besstest.m      -- A test script.
%	    besselmx.f      -- Fortran source for Mex file and Amos library.
%	    besselmx.mex    -- Compiled Mex file for MS Windows.
%	    besselmx.mex4   -- Compiled Mex file for Sparc (Sun4)
%	    besselmx.mexsol --  Compiled Mex file for Sparc (Sol2)            
%	    besselmx.mexhp7 -- Compiled Mex file for HP700.
%	    besselmx.<arch> -- Compiled Mex file for other machines.
%
%	The files should be installed in directory toolbox/matlab/specfun,
%	replacing the older bessel*.m files.
%
%	C. Moler, 4/10/94
%	Copyright (c) 1984-94 by The MathWorks, Inc.

[w,ierr] = besselj(nu,z);
