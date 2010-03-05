function [s] = wrapFunctions(s)

% wrapFunctions (SUMO)
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
%	[s] = wrapFunctions(s)
%
% Description:
%	Create anonymous function handles to wrap all operator functions to members of the given obj
%	The genetic operator functions are memberfunctions and thus need to be called with the 'this' object (s).
%	To make this possible we need to wrap them in an anonymous function. And set them again as function handles.

mutFcn = s.mutationFcnStr;
xoFcn = s.crossoverFcnStr;
crFcn = s.creationFcnStr;
conFcn = s.constraintFcnStr;

customType = false;

%If the mutation or crossover function starts with a '@' it is a built in 
%function and nothing else need be done.
if(mutFcn(1) ~= '@')
	mutFcn = ['@(p, o, n, fcn, st, sc, pop) ' mutFcn '(s, p, o, n, fcn, st, sc, pop)'];
	customType = true;
end

if(xoFcn(1) ~= '@')
	xoFcn = ['@(p, o, n, fcn, un, pop) ' xoFcn '(s, p, o, n, fcn, un, pop)'];
	customType = true;
end

if(crFcn(1) ~= '@')
	crFcn = ['@(g, fcn, o) ' crFcn '(s, g, fcn, o)'];
	customType = true;
end

if(~strcmp(conFcn,'[]'))
	conFcn = ['@(x) ' conFcn '(s, x)'];
	s.constraintFcn = eval(conFcn);
else
	s.constraintFcn = [];
end

%Set the actual function handles
s.mutationFcn = eval(mutFcn);
s.crossoverFcn = eval(xoFcn);
s.creationFcn = eval(crFcn);
s.customMode = customType;
