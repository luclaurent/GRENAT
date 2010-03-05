function [out1 out2] = MOTestFunction1(varargin)

% MOTestFunction1 (SUMO)
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
%	[out1 out2] = MOTestFunction1(varargin)
%
% Description:
%	A simple funciton with two outputs to use for Multi Objective modeling

% create input array
in = [varargin{:}];

a = in(:,1);
b = in(:,2);

% something smooth: rosenbrock
out1 = (1 - a).^2 + 100 *(b - a.^2).^2;

% something bumpy: ackley
out2 = ackleyfun([a b]);

	function res = ackleyfun(in)
		n = 2;
		a = 20;
		b = 0.2;
		c = 2*pi;
		
		res = zeros(size(in,1),1);
		for i = 1:size(in,1)
			p = in(i,:);
			res(i) = - a * exp( -b * sqrt( (1/n) * sum(p .^ 2))) - exp((1/n) * sum(cos(c .* p))) + a + exp(1);
		end	
	end

end
