function [singleton] = Singleton(singletonName, singletonObject)

% Singleton (SUMO)
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
%	[singleton] = Singleton(singletonName, singletonObject)
%
% Description:
%	Singleton allows the user to create a unique, global object that can be
%	referenced from multiple locations and can be passed by reference
%	instead of by value as is normally always the case in Matlab.
%	This function returns the singleton with name singletonName when it is
%	called with one argument, or initializes the singleton with name
%	singletonName to object singletonObject when it is called with two
%	arguments.
%	Example use of the Singleton class:
%	x = {'test' [1 2 3 4]}			% create object
%	Singleton('mySingleton', x)		% register as singleton
%	s1 = Singleton('mySingleton');	% get first reference to x
%	s2 = Singleton('mySingleton');	% get second reference to same x
%	s1.obj{2} = [s.obj{2} 5];		% append to array
%	s2.obj{3} = 'test2';			% add third object to cell array
%	celldisp(s2.obj);				% 'test' [1 2 3 4 5] 'test2'
%	s2.obj{2}(3)					% 3
%	s2{2}(3)						% shortcut for s2.obj{2}(3), also returns 3

	  

% default constructor
if ~exist('singletonName', 'var')
	return;
end

% the variable which will contain all singletons
persistent singletons;

% initialize variable listing
if isempty(singletons)
	singletons = struct;
end


% see if we have to initialize the singleton
if exist('singletonObject', 'var')

	% add singleton to table
	singletons.(singletonName) = singletonObject;

% no need to initialize the singleton, we just return it from the table
else

	% check for existence
	if ~isfield(singletons, singletonName)
		error('Unitialized singleton with name %s requested, aborting...', singletonName);
	end

	% get singleton
	singleton = singletons.(singletonName);
end

end

