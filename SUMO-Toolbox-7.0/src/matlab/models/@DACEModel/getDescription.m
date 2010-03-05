function desc = getDescription( this )

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
% Revision: $Rev: 6376 $
%
% Signature:
%	desc = getDescription( this )
%
% Description:
%	Return a user friendly description of the model

theta = cell( 1, length( this.config.func ) );
corrfunc = {};
for i=1:length( this.config.func )
	theta{i} = this.config.func(i).theta;
	corrfunc{i} = this.config.func(i).name;
end

desc = sprintf('DACE model with regression function %s and correlation functions: ','chebyshevBase');

tmp = [corrfunc{1} ' (theta = ' arr2str(theta{i}) ')'];

for i=2:length(theta)
    tmp = [tmp ', ' corrfunc{i} ' (theta = ' arr2str(theta{i}) ')'];
end

desc = [desc tmp];
