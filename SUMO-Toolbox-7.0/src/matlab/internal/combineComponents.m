function [objects, outputCoverage] = combineComponents( nodes, oldConfig )

% combineComponents (SUMO)
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
%	[objects, outputCoverage] = combineComponents( nodes, oldConfig )
%
% Description:
%	When combineOutputs is set to on in the config, multiple instances of
%	the same object for different outputs are combined as one, and only one
%	object of that type is instantiated.

import ibbt.sumo.config.*;
import java.util.logging.*;

% walk all component configurations
objects = {};
outputCoverage = {};
for i = 1 : length(nodes)
	
	% this node was already processed and combined into one, skip!
	if isempty(nodes{i})
		continue;
	end
	
	% get node
	node = nodes{i};
	
	% Wrap in a NodeConfig object
	if ~isa( node, 'NodeConfig' )
		node = NodeConfig.newInstance(node);
	end
	
	% create a copy of the parent config
	config = oldConfig.clone();
	
	% Get object type
	id = char(node.valueOf('@id'));
		
	% now see if this object is configured to combine outputs
	combineOutputs = node.getBooleanAttrValue('combineOutputs', 'true');

	% yes, we must combine outputs
	if combineOutputs

		% look for other outputs that are configured using the same
		% component
		toCombine = i;
		for j = i+1 : length(nodes)

			% node already processed and combined into one, skip
			if isempty(nodes{j})
				continue;
			end

			otherId = char(nodes{j}.valueOf('@id'));

			% this id matches the other id -> combine
			if strcmp(id,otherId)

				% add to combination list
				toCombine = [toCombine j];

				% remove from todo list
				nodes{j} = [];
			end

		end

	% don't combine outputs, but we still must process this one
	else
		toCombine = i;
	end

	% filter outputs
	config.output = FilteredOutputConfig(config.output, toCombine - 1);

	% finally instantiate this component
	newObject = instantiate(node, config);

	% add object to list of objects
	objects = [objects {newObject}];
	% add output coverage to list
	outputCoverage = [outputCoverage toCombine];
	
end
