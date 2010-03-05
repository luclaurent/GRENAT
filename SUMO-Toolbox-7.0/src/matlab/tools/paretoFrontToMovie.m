function res = paretoFrontToMovie( directory, types, xl, yl, logScale )

% paretoFrontToMovie (SUMO)
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
%	res = paretoFrontToMovie( directory, types, xl, yl, logScale )
%
% Description:
%	Generate a movie of all pareto front objects

if(~exist('types','var'))
    types = [];
end

if(~exist('xl','var'))
    xl = [0 1];
end

if(~exist('yl','var'))
    yl = [0 1];
end

if(~exist('logScale','var'))
	logScale = 1;
end

% load a directory of pareto fronts
pfs = dir([directory '/*.mat']);

for i=1:length(pfs)
	name = pfs(i).name;
    tmp = [directory '/' name];
	plotModelParetoFront(tmp,types,xl,yl,logScale);
	
    saveas(gcf,fullfile(directory,[name '.png']));

	close all
end

images2movie(directory,'paretoFrontEvolution.mov','png',2);

