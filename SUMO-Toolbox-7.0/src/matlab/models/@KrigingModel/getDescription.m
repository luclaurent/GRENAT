function desc = getDescription(this)

% getDescription (SUMO)
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
% Revision: $Rev: 6401 $
%
% Signature:
%	desc = getDescription(this)
%
% Description:
%	Return a user friendly model description

%    desc = sprintf('Kriging model with theta: %s, regression fcn: %s and correlation fcn: %s',arr2str(this.theta),this.regressionFcn, this.correlationFcn);

[dummy regressionFunc] = this.regressionFunction('latex', false, 'includeCoefficients', false );
correlationFunc = this.correlationFunction();

hp = sprintf('%.02f ', this.getHp() );

name = correlationFunc.getName();
[dummy hpnames] = correlationFunc.getHpNames();

desc = sprintf('Blind Kriging model with correlation function %s: %s=( %s) and regression function %s\nlambda=%.02f\n', ...
    name, hpnames, hp, regressionFunc, this.getLambda() );

