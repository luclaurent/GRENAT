classdef ScaleByConstant < DataModifier

% ScaleByConstant (SUMO)
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
%	ScaleByConstant(config)
%
% Description:
%	Scales the data by a constant

  properties
    constant;
  end

  methods
    function this = ScaleByConstant(config)
      this = this@DataModifier(config);

      this.constant = config.self.getDoubleAttrValue('constant', '1');
    end

    function [out this] = modify(this,in)
      out = in .* this.constant;
    end

  end
end
