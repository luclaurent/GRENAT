function map = ensembleFriends( types, maxSize, models )

% ensembleFriends (SUMO)
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
%	map = ensembleFriends( types, maxSize, models )
%
% Description:
%	Generates a bar chart showing how ofen two model types are paired
%	together inside an ensemble in a population of models

%TODO fix for higher dims!

numTypes = length(types);

if(maxSize < 2 || numTypes < 2)
  error('Not enough types or ensemble size is too small')
end

typeMap = struct();

% Map model types onto an index
% start at 2, index 1 means no value for that dimension
for i=2:numTypes+1
  typeMap.(types{i-1}) = i;
end

% the actual map, we have numTypes labels for the first two dimensions and
% numTypes+1 for all dimensions above 2 (we add the none label)
if(maxSize > 2)
    map = zeros( [repmat(numTypes,1,2) repmat(numTypes+1,1,maxSize-2)] );
else
    map = zeros( repmat(numTypes,1,maxSize) );
end

for i=1:length(models)
  m = models{i};
  if(isa(m,'EnsembleModel'))
    mods = getModels(m);
    indices = zeros(1,length(mods));
  
    % get the indices of the model types in the type map
    for j=1:length(mods)
      m1 = mods{j};
      indices(j) = typeMap.(class(m1));
    end
    
    %if the ensemble size is less than maxSize, pad with 1's for the other
    %dimensions (actually we pad with 2s then subtract 1)
    if(length(mods) < maxSize)
      indices = [indices (ones(1,maxSize - length(mods))*2)];
    elseif(length(mods) > maxSize)
      error('Invalid ensemble size!')
    else
      % do nothing
    end
    
    % subtract one since we started counting at 2
    indices = indices - 1;

    % add the counter for the corresponding cell in the map
    if(maxSize == 2)
      map(indices(1),indices(2)) = map(indices(1),indices(2)) + 1;
    elseif(maxSize == 3)
      map(indices(1),indices(2),indices(3)) = map(indices(1),indices(2),indices(3)) + 1;
    elseif(maxSize == 4)
      map(indices(1),indices(2),indices(3),indices(4)) = map(indices(1),indices(2),indices(3),indices(4)) + 1;
    else
      error('Unsupported ensemble size!')
    end
  else
    % ignore
  end
end

% project on the first two dimensions so we can plot it
if(maxSize == 2)
  map2d = map;
elseif(maxSize == 3)
  map2d = sum(map,3);
elseif(maxSize == 4)
  map2d = sum(sum(map,4),3);
else
    error('Unsupported ensemble size');
end

% ANN - SVM ensemble is the same as SVM - ANN so add those together
tl = tril(map2d,-1);
tu = triu(map2d,1);
d = diag(map2d); % keep the diagonal separate, dont count it twice

% build the final map
m = tl + tu' + diag(d);

% plot it
figure
bar3(m)
set(gca,'FontSize',14);
set(gca,'XTickLabels',[types],'FontSize',14)
set(gca,'YTickLabels',[types],'FontSize',14)
