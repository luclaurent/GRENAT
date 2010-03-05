classdef Degrees

% Degrees (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 6376 $
%
% Signature:
%	Degrees( varargin )
%	getNDegrees(s)
%
% Description:
%	Construct a degree class.
%	1/ Copy constructor
%	2/ Restore after serialization (takes struct argument)
%	3/ Construct with weight vector `w' and flag vector `f'
%
%	The `degrees' class provides the polynomial class with
%	suitable degree sets, according to the weighting `w' and
%	the numerator/denominator flags `f'.
%	See the docs for a more elaborate expl.

  properties(Access = private)
	weights = 0;
	dimension = 0;
	degrees = 0;
	level = 0;
	sums = 0;
	marks = 0;
	flags = 0;
  end

  methods(Access = public)
    function s = Degrees( varargin )
		
      if(nargin == 0)
	% do nothing, keep defaults

      elseif(nargin == 2)
	w = varargin{1};
	f = varargin{2};
	if ~all( w == fix(w) ) || ~all( w > 0 )
		error( 'When constructing using weight vector all should be positive integers' );
	end

	if length(size(w)) ~= 2 || ~any( size(w) == 1 )
		error( 'Weight vector must be a vector (doh)' );
	end
	
	if any( size( f ) ~= size( w ) )
		error( 'F must be of same size as w' );
	end

	s.weights = w(:).';
	s.dimension = length(w);
	s.degrees = zeros(1,s.dimension);
	s.level = 0;
	s.sums = 1;
	s.marks = 0;
	s.flags = f(:);
      else
	error('Invalid number of input arguments')
      end
    end

    function res = getWeights(s)
      res = s.weights;
    end

    function res = getDimension(s)
      res = s.dimension;
    end

    function res = getFlags(s)
      res = s.flags;
    end

    function res = getNDegrees(s)
      res = size( s.degrees, 1 );
    end

    [N,D] = getDegrees(s, n);
    s = update( s, n );

  end 

   methods(Access = private)
    solution = diophantine( w, k )
    solution = diophantineRecurse( w,k,lev,curr )
   end

end
