classdef Noise < DataModifier

% Noise (SUMO)
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
%	Noise(config)
%
% Description:
%	Introduces noise to the data.

  properties
    distribution;
    variance;
  end

  methods
    function this = Noise(config)
      this = this@DataModifier(config);

      % get the type of the noise
      this.distribution = char(config.self.getAttrValue('distribution', 'normal'));

      % get the variance of the noise
      this.variance = config.self.getDoubleAttrValue('variance', '.01');
    end

    function [out this] = modify(this,in)
      switch this.distribution
	
	case 'normal'
		out = in + (randn(size(in)) .* this.variance);
		
	case 'uniform'
		out = in + ((rand(size(in)) .* 2 - 1) .* this.variance); 	
	end
    end

  end
end
