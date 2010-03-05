function groupCell = groupModels(s,indices,population);

% groupModels (SUMO)
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
%	groupCell = groupModels(s,indices,population);
%
% Description:
%	Given a cell of models this function will return a cell array where each cell contains
%	indices of models of the same type

groups = struct();

for i=1:length(indices)
    idx = indices(i);
    m = population{idx};
    t = class(m);
    
    % ok, so m is the model with type t and with index idx in the population
    
    % does the group for model type t exist yet?
    if(~isfield(groups,t))
        % no, create it
        groups.(t) = [];
    end
    
    % now add the index
    groups.(t) = [groups.(t) idx];
end

% how many groups do we have
fnames = fieldnames(groups);
n = length(fnames);

% Now return a cell of all the group indices
groupCell = cell(1,n);

for i=1:n
    groupCell{i} = groups.(fnames{i});
end


