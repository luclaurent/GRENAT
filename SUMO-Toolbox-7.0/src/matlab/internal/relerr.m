function out1=relerr(varargin)

% relerr (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	out1=relerr(varargin)
%
% Description:
%	Relative error performance function for use when training Matlab Neural
%	Network ojbects

fn = mfilename;
boiler_perform

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Info
function info = function_info

info.function = mfilename;
info.title = name;
info.type = 'Performance';
info.version = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Name
function n = name
n = 'Relative Error';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Defaults
function fp = param_defaults()
fp = struct;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Names
function names = param_names
names = {};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Check
function err = param_check(fp)
err = {};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply Performance Function
function perf = performance(e,y,x,fp)

dontcares = find(~isfinite(e));
e(dontcares) = 0;
perf = sum(abs(sum(e ./ y ,2) ./ size(e,2)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative of Perf w/respect to Y
function d = derivative_dperf_dy(e,y,x,perf,fp)

dontcareindices = find(~isfinite(e));
numdontcares = length(dontcareindices);
e(dontcareindices) = 0;

% *** CUSTOMIZE HERE
% *** Calculate derivative of performance with respect to outputs Y
% *** This should include contributions of both error and any direct effect
% *** of outputs.
numElements = prod(size(e)) - length(dontcares);
if (numElements == 0)
  d = zeros(size(e));
else
  d = abs((e - y) ./ (y .^ 2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative of Perf w/respect to X
function d = derivative_dperf_dx(t,y,x,perf,fp)

d = zeros(size(x));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
