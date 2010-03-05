function m = createModel(s,individual);

% createModel (SUMO)
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
%	m = createModel(s,individual);
%
% Description:
%	Given an individual representing a model, return a real model

[samples values] = getSamples(s);

if(~exist('individual','var') || isempty(individual))
    % create a default model
    params = [s.kernelParamBounds(1) + ((s.kernelParamBounds(2) - s.kernelParamBounds(1)) / 2) ...
        s.regParamBounds(1) + ((s.regParamBounds(2) - s.regParamBounds(1)) / 2) ];
    
    m = genModel(s.backend,s.type,s.kernel,params(1),params(2));
else
    if(isa(individual,'Model'))
        m = individual;
    else
        m = genModel(s.backend,s.type,s.kernel,individual(1),individual(2));
    end
end

m = m.setMode(s.getMode());

function m = genModel(backend,type,kernel,kp,rp)
if(strcmp(kernel,'lin'))
    kp = [];
elseif(strcmp(kernel,'poly'))
    kp = max(0,round(kp));
else
    % do nothing
end

m = SVMModel(backend,type,kernel,kp,rp);
