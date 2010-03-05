function this = updateModel( this, F, hyperparameters, lambda )

% updateModel (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	this = updateModel( this, F, hyperparameters, lambda )
%
% Description:
%	Constructs model

	%% correlation
	[this err] = updateCorrelation( this, hyperparameters, lambda );
	if ~isempty( err )
		error([err '(updateCorrelation)']);
	end
	
	%% regression (get least squares solution)
	[this err] = updateRegression( this, F );
	if ~isempty( err )
		error([err '(updateRegression)']);
	end

    %% What is needed for prediction
    % polynomial part: alpha
    % correlation part: gamma, hyperparameters, corr func
    % for prediction variance: sigma2, C, R, Ft
end
