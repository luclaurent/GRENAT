function s = removeDuplicates( s )

% removeDuplicates (SUMO)
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
%	s = removeDuplicates( s )
%
% Description:
%	Remove duplicate ensemble members

newModels = {};
cmpMatrix = eye(length(s.models));

for i=1:length(s.models)
	for j=i+1:length(s.models)
		if(equals(s.models{i},s.models{j},s.eqThreshold))
			cmpMatrix(i,j) = 1;
		else
			cmpMatrix(i,j) = 0;
		end
	end
end

%Copy the upper triangle to the lower triangle since the matrix is symmetrical
cmpMatrix = triu(cmpMatrix,1) + triu(cmpMatrix,1)' + eye(length(s.models));

%disp('--- start removeDuplicates')
%getDescription(s)
%cmpMatrix

%Get all the rows where the row sum is 1 (unique models)
tmp = sum(cmpMatrix,1);
uniqueModels = find(tmp == 1);

%Save them
newModels = s.models(uniqueModels);

%Get all the indices of the rows with duplicates
duplicateModels = find(tmp > 1);

%For each duplicate only retain the first one
added = [];
for i=1:length(duplicateModels)
	%Get the row of the duplicate model
	tmp = cmpMatrix(duplicateModels(i),:);

	%Add its occurence on the diagonal (unless already added)
	if(length( find(added == duplicateModels(i)) ) == 0)
		newModels(end+1) = s.models(duplicateModels(i));
	
		%Mark all its occurences as added
		added = [added find(tmp > 0)];
	end
end

%replace the current models with the new models (duplicates removed)
s.models = newModels;

%getDescription(s)
%disp('end removeDuplicates ---')

% reset the weights
s = setWeights(s,1);
