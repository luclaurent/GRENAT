function [c1 c2] = onePointCrossover(p1,p2,keepSize);

% onePointCrossover (SUMO)
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
%	[c1 c2] = onePointCrossover(p1,p2,keepSize);
%
% Description:
%	Do a one point crossover between two vectors

if(length(p1) == 0 || length(p2) == 0)
  error('Vectors may not be null')
end

if(~isvector(p1) || ~isvector(p2) || (size(p1,2) ~= size(p2,2)))
  error('Both parents must be vectors with the same orientation');
end

% is it a row vector?
isRowVec = (size(p1,2) > 1);

if(keepSize == true)
	pivot1 = randomInt(1,min(length(p1),length(p2))-1);
	pivot2 = pivot1;
else
	pivot1 = randomInt(1,length(p1)-1);
	pivot2 = randomInt(1,length(p2)-1);
end

if(isRowVec)
  c1 = [p1(1:pivot1) p2(pivot2+1:end)];
  c2 = [p2(1:pivot2) p1(pivot1+1:end)];
else
  c1 = [p1(1:pivot1) ; p2(pivot2+1:end)];
  c2 = [p2(1:pivot2) ; p1(pivot1+1:end)];
end
