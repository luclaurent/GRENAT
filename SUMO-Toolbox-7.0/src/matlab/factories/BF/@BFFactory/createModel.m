function m = createModel(s, individual)

% createModel (SUMO)
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
%	m = createModel(s, individual)
%
% Description:

if(~exist('individual','var') || isempty(individual))

  error('This feature is not supported (yet) by BFFactory');

elseif(isa(individual,'Model'))

   m = individual;

else
    % Make parameters into matrix, one colunm per (percieved) dimension
    parameters = reshape( individual, s.nparam, getDim(s) );

    % Create a suitable basis function descriptor for each dimension
    basefun = struct;

    for k=1:getDim(s)
	if length( s.functions ) == 1
	    basisFunction = s.functions;
	    param = parameters(:,k);
	else
	    % Map first parameter to a `bucket' matching one basis function
	    selector = fix( length(s.functions) * parameters(1,k) - eps ) + 1;
	    basisFunction = s.functions(selector);
	    param = parameters(2:1+length(basisFunction.min),k);
	end
	
	% Basis function name (String) and function handle (@Handle)
	basefun(k).name = basisFunction.name;
	basefun(k).func = basisFunction.func;
	
	% This just maps [0-1] to the parameter range for the specified BF
	basefun(k).theta = scaleIn( s, param, basisFunction );
    end


    % Construct model configuration structure
    modelConfig = struct( ...
	    'func',				basefun, ...
	    'degrees',			0, ...
	    'backend',			getBackend(s), ...
	    'targetAccuracy',	0.005 ...   % See below
    );
    % On targetAccuracy : Unused if backend = Direct, 
    % Target accuracy in all other cases, select this one carefully, making
    % it to small will slow down convergence considerably, or prevent
    % convergence altogether... See the backend's implementation for details of
    % its meaning...

    % Works for both RBF and DACE (that's why there is only a BFInterface)...
    m = makeModel( s, modelConfig );
end
