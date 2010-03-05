function obs = getObservables( s )

% getObservables (SUMO)
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
% Revision: $Rev: 6402 $
%
% Signature:
%	obs = getObservables( s )
%
% Description:

[ni no] = getDimensions(s);

obs = { ...
        SimpleObservable( ...
            'hyperparameters', ...
            'The Hyperparameters', ...
            'KrigingModel', ...
            @(x) x.getHp(), ...
            ni ), ...
        SimpleObservable( ...
            'cvpe', ...
            'Cross validated prediction error', ...
            'KrigingModel', ...
            @(x) x.cvpe(), ...
            no ), ...
        SimpleObservable( ...
            'regression', ...
            'Regression function', ...
            'KrigingModel', ...
            @(x) selectOutput(@x.regressionFunction, [2], 'latex', false, 'includeCoefficients', false), ...
            1 ), ...
        SimpleObservable( ...
            'correlation', ...
            'Correlation function', ...
            'KrigingModel', ...
            @(x) selectOutput(@x.correlationFunction, [2]), ...
            1 ), ...
		SimpleObservable( ...
            'lambda', ...
            'Amount of regression 10^lambda', ...
            'KrigingModel', ...
            @(x) x.getLambda(), ...
            1 ), ...
		SimpleObservable( ...
            'sigma2', ...
            'Process variance', ...
            'KrigingModel', ...
            @(x) x.getProcessVariance(), ...
            1 ) ...
    };
