classdef Outlier < DataModifier

% Outlier (SUMO)
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
%	Outlier(config)
%
% Description:
%	Introduces noise to the data.

  properties
    type;
    frequency;
    number;
    force;
    counter;
  end

  methods
    function this = Outlier(config)
      this = this@DataModifier(config);

      this.type = char(config.self.getAttrValue('method', 'multiply'));
      this.frequency = config.self.getDoubleAttrValue('frequency', '100');
      this.number = config.self.getDoubleAttrValue('number', '1');
      this.force = config.self.getDoubleAttrValue('value', '100');
      this.counter = 0;
    end

    function [out this] = modify(this,in)
      out = in;

      for i = 1:size(in,1)
	  this.counter = mod(this.counter,this.frequency);
	  if  this.counter < this.number
		  switch this.type
			  case 'multiply'
				  out(i) = in(i) * this.force;
			  case 'add'
				  out(i) = in(i) + this.force; 
		  end
	  end
	  this.counter = this.counter + 1;
      end
    end

  end
end
