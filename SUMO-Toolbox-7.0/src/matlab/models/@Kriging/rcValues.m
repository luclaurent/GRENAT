function rc = rcValues(this)

% rcValues (SUMO)
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
%	rc = rcValues(this)
%
% Description:
%	EXPERIMENTAL
%	robustness-criterion (In theory only for ordinary kriging)
%	See "Kriging models that are robust w.r.t. simulation errors"
%	by A.Y.D. Siem, D. den Hertog (tech report)
%	Quantifies magnification of noise (lower is better)

    rc = zeros( 2, size(this.gamma,1) );
    
    for i=1:size(this.gamma,1)
        
        % absolute
        rc(1,i) = norm( this.gamma(i,:), 2 ).^2;
    
        % relative
        rc(2,i) = rc(1,i) ./ norm( this.gamma(i,:), inf );
    end

end
