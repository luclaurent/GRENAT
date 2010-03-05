classdef Failure < DataModifier

% Failure (SUMO)
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
%	Failure(config)
%
% Description:
%	Introduces failed simulations to the data (NaN's).

  properties
    chance;
  end

  methods
    function this = Failure(config)
      this = this@DataModifier(config);

      % get the chance of simulations failing
      this.chance = config.self.getDoubleAttrValue('chance', '.1');
    end

    function [out this] = modify(this, in)
      out = in;

      % generate chance% NaN's
      odds = rand(size(out));

      % create NaN's
      out(odds < this.chance) = NaN;
    end
  end
end
