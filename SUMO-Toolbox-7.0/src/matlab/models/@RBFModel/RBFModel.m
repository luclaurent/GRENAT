classdef RBFModel < Model

% RBFModel (SUMO)
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
%	RBFModel( varargin )
%
% Description:
%	Constructs a radial basis function model object.

 properties(Access = private)
    config = 0;
    fit = struct;
  end
	
  methods(Access = public)
    
    function this = RBFModel( varargin )
      if nargin < 1
	% do nothing
      elseif nargin == 1
	this.config = varargin{1};
      else
	error('Too many parameters passed' );
      end

      if nargin == 1
	% Test whether basisfunction is supported by the backend, discard return value
	translateBasisFunction( this );
      end
    end

    function desc = getDescription(this)
      desc = sprintf( 'RBF model using backend %s and basis function %s.', this.config.backend, this.config.func.name );
    end

    this = constructInModelSpace(this, samples, values);
    [values] = evaluateInModelSpace(this, points);
    [values] = evaluateMSEInModelSpace(this, points);

  end

  methods(Access = private)
    [s,residues] = buildRegressionPart( s, samples, values );
    s = directFit( s, samples, values );
    bf = translateBasisFunction( s );
  end

end
