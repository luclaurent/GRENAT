classdef DataModifier

% DataModifier (SUMO)
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
%	DataModifier(config)
%
% Description:
%	A DataModifier modifies data coming from a simulator, for example
%	introducing noise, or taking the log

  properties
  end

  methods
    function this = DataModifier(config)
      import ibbt.sumo.config.*;
      % nothing to do
    end
  end

  methods(Abstract = true)
    [out this] = modify(this, in);
  end

end
