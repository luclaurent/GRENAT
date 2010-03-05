function [newPop newScores] = extinctionPrevention(s, sz,prevPop, prevScores, curPop, curScores, minCount)

% extinctionPrevention (SUMO)
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
%	[newPop newScores] = extinctionPrevention(s, sz,prevPop, prevScores, curPop, curScores, minCount)
%
% Description:
%	Make sure there are at least minCount individuals of each model type in the population

import ibbt.sumo.util.*;

if(length(prevPop) == 0)
	newPop = curPop;
	newScores = curScores;
	return;
end

% detect if we are in multi-objective mode, ie, scores has more than 1 column
multiObjMode = size(curScores,2) > 1;

if(multiObjMode)
  % if so, we have to scalarize the scores since extinction prevention wont work otherwise
  % so just take the distance to the origin to create a linear ranking
  tmpCurScores = sqrt(sum(curScores .^ 2,2));  
  tmpPrevScores = sqrt(sum(prevScores .^ 2,2));
else
  tmpCurScores = curScores;  
  tmpPrevScores = prevScores;
end

%Sort the scores from best to worst
[sortedPrevScores prevScoresIndices] = sort(tmpPrevScores,1,'ascend');
[sortedCurScores curScoresIndices] = sort(tmpCurScores,1,'ascend');

cTypes = {};
cScores = [];
cIndices =[];
for i=1:length(curPop)
	cTypes = [cTypes class(curPop{curScoresIndices(i)})];
	cScores = [cScores curScores(curScoresIndices(i))];
	cIndices = [cIndices curScoresIndices(i)];
end

pTypes = {};
pScores = [];
pIndices =[];
for i=1:length(prevPop)
	pTypes = [pTypes class(prevPop{prevScoresIndices(i)})];
	pScores = [pScores prevScores(prevScoresIndices(i))];
	pIndices = [pIndices prevScoresIndices(i)];
end


e = ExtinctionPrevention(cTypes,cIndices,cScores,pTypes,pIndices,pScores,minCount);
e.doIt();

replacements = e.getReplacementList();

newPop = curPop;
newScores = curScores;

for i=1:size(replacements,1)
	newPop{replacements(i,1)} = prevPop{replacements(i,2)};	
	newScores(replacements(i,1),:) = prevScores(replacements(i,2),:);
end

%  if(length(replacements) > 0)
%  	disp('------------- replacements --------------')
%  	replacements
%  	disp('------------- before prevention ----------')
%  	printHeteroPop(sz,curPop,curScores);
%  	disp('------------- cur sizes ----------')
%  	[sizes ts] = printSizes(curPop);
%  	disp('------------- prev sizes ----------')
%  	[sizes ts] = printSizes(prevPop);
%  	disp('------------- after prevention ----------')
%  	printHeteroPop(sz,newPop,newScores);
%  	[sizes ts] = printSizes(newPop);
%  	
%  	if(length(ts) < 3)
%  		cTypes
%  		cIndices
%  		cScores
%  		pTypes
%  		pIndices
%  		pScores,
%  		error('******* asdfasdfasdfasdf*******')
%  	end
%  
%  	disp('------------------------------------------')
%  end


%  function [sizes ts] = printSizes(models)
%  	disp('---- Population sizes are:')
%  	map = java.util.Hashtable();
%  	
%  	types = {};
%  	for i=1:length(models)
%  		t = models(i).type;
%  		if(map.containsKey(t))
%  			map.put(t,map.get(t)+1);
%  		else
%  			map.put(t,1);
%  			types = [types t];
%  		end
%  	end
%  	
%  	sizes = [];
%  	ts = [];
%  	for i=1:length(types)
%  		t = types{i};
%  		s = map.get(t);
%  		
%  		disp(sprintf('%d models of type %s',s,t));
%  		sizes = [sizes s];
%  		ts = [ts t];
%  	end
%  	disp('Population sizes are ----')
