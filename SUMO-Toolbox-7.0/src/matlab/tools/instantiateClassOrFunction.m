function [object] = instantiateClassOrFunction(node, oldConfig, defaultType)

% instantiateClassOrFunction (SUMO)
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
%	[object] = instantiateClassOrFunction(node, oldConfig, defaultType)
%
% Description:
%	This function is responsible for instantiating an object based on a
%	node from the config. If the type specified in the node corresponds to
%	a function, the defaultType is instantiated instead, and the
%	defaultType should use the function internally. If it is a class, the
%	type is instantiated using instantiate().

import ibbt.sumo.config.*;
import ibbt.sumo.config.*;
import java.util.logging.*;
logger = Logger.getLogger('Matlab.instantiateClassOrFunction');

% get type field - must point to subclass of defaultType
type = char(node.valueOf('@type'));

% first check for a type attribute - if type does not exist, this must be a
% reference by id to an object which is defined elsewhere in the config
if strcmp(type, '')
    
    % get the id from the content of the node
    id = node.getText().trim();
    
    % try to resolve the reference
    node = ConfigUtil.resolveReference(parentConfig.base, node.getName(), id);
    
    % failed to resolve the reference
    if isempty(node)
        msg = sprintf('Failed to instantiate component of type ''%s'' with id ''%s''', node.getName(), id);
        logger.severe(msg);
        error(msg);
    end
    
    % instantiate the refered node, instead of the original one
    [object] = instantiateClassOrFunction(node, parentConfig, defaultType);
    
    % all done
    return;
end

% see if this is a class or function
if isempty(meta.class.fromName(type))
    
    % Wrap in a NodeConfig object
    if ~isa( node, 'NodeConfig' )
        node = NodeConfig.newInstance(node);
    end
    
    % create copy of config
    config = oldConfig.clone();
    config.self = node;
	
	try
		% create default type... this will internally use the function for
		% performing the action instead of a subclass of the default type
		object = eval([defaultType '(config)']);
	catch err
		msg = sprintf('Failed to create object of type %s, error is "%s', type, err.message);
		logger.severe(msg);
		printStackTrace( err.stack, logger, Level.SEVERE );
		error(msg);
	end
	

	
% class - instantiate it normally
else
	object = instantiate(node, oldConfig);
end


% make sure the subclass matches
if ~isa(object, defaultType)
	msg = sprintf('Object of type %s is not a subclass of %s', type, defaultType);
	logger.severe(msg);
	printStackTrace(err.stack, logger, Level.SEVERE);
	error(msg);
end


end
