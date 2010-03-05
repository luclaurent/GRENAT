function [object] = instantiate(node, parentConfig)

% instantiate (SUMO)
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
%	[object] = instantiate(node, parentConfig)
%
% Description:
%	This function is responsible for instantiating an object based on a
%	node from the config. This node is then used to fetch data about this
%	object from the config, and to instantiate the object with the
%	appropriate settings and data.

import ibbt.sumo.config.*;
import ibbt.sumo.config.*;
import java.util.logging.*;
logger = Logger.getLogger('Matlab.instantiate');

% get type and id fields
type = char(node.valueOf('@type'));

% first check for a type attribute - if type does not exist, this must be a
% reference by id to an object which is defined elsewhere in the config
if strcmp(type, '')
    
    % get the id from the content of the node
    id = char(node.getText().trim());
    
    nodeName = char(node.getName());
    
    % try to resolve the reference
    node = ConfigUtil.resolveReference(parentConfig.base, nodeName, id);
    
    % failed to resolve the reference
    if isempty(node)
        msg = sprintf('Failed to instantiate component of type ''%s'' with id ''%s''', nodeName, id);
        logger.severe(msg);
        error(msg);
    end
    
    % instantiate the refered node, instead of the original one
    [object] = instantiate(node, parentConfig);
    
    % all done
    return;
end


% create a copy of the parent config
config = parentConfig.clone();

% Wrap in a NodeConfig object
if ~isa( node, 'NodeConfig' )
	node = NodeConfig.newInstance(node);
end

% set self in config
config.self = node;

% remember our parent
config.parent = parentConfig.self;

% create the object
try
    % do the actual instantiation
    object = eval([type '(config)']);

catch err
    msg = sprintf('Failed to create object of type %s, error is "%s', type, err.message );
    logger.severe(msg);
    printStackTrace( err.stack, logger, Level.SEVERE );
    error(msg);
end

