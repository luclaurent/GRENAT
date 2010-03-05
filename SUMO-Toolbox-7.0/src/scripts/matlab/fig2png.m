function fig2png(directory, recurse, strFilter)

% fig2png (SUMO)
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
%	fig2png(directory, recurse, strFilter)
%
% Description:
%	Convert all fig files in the given directory to png files

if(~exist('recurse'))
	recurse = 0;
end

if(~exist('strFilter'))
	strFilter = '';
end

if(recurse)
	files = subdir([directory '/*.fig']);
else
	files = dir([directory '/*.fig']);
end

n = length(files);

for i=1:n
	name = files(i).name;
	if((length(strFilter) == 0) || (length(strfind(name,strFilter)) > 0))
		hgload(name);
		saveas(gcf,sprintf('%s.png',name(1:end-4)));
		close;
	end
end
