function replotModels(directory, outputIndex, options, recurse, strFilter)

% replotModels (SUMO)
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
%	replotModels(directory, outputIndex, options, recurse, strFilter)
%
% Description:
%	Load all models saved as mat files and replot/resave them using the given output index and options

if(~exist('outputIndex'))
	outputIndex = 1;
end

if(~exist('options') || isempty(options))
	%Use defaults
	[d options] = plotModel(RationalModel);
end

if(~exist('recurse'))
	recurse = 0;
end

if(~exist('strFilter'))
	strFilter = '';
end

if(recurse)
	files = subdir([directory '/*.mat']);
else
	files = dir([directory '/*.mat']);
end

n = length(files);

for i=1:n
	name = files(i).name;
	if((length(strFilter) == 0) || (length(strfind(name,strFilter)) > 0))
		m = load([directory '/' name]);
		m = m.model;
		plotModel(m,outputIndex,options);
		saveas(gcf,sprintf('%s/%s.png',directory,name(1:end-4)));
		close;
	end
end
