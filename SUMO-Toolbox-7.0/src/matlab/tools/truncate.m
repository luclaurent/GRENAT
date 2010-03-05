function x = truncate(varargin )

% truncate (SUMO)
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
%	x = truncate(varargin )
%
% Description:
%	truncate first parameter (scalar or array)
%	so that it lies between `mn' and `mx'
%	specified as truncate(val,mn,mx) or truncate(val,[mn,mx])
%
%	Example:
%	> truncate( [1 2 ; 5 6], 2, 5 )
%	ans = [2 2 ; 5 5]

if(nargin == 3)
      val = varargin{1};
      mn = varargin{2};
      mx = varargin{3};
elseif(nargin == 2)
    val = varargin{1};
    tmp = varargin{2};
    mn = tmp(1);
    mx = tmp(2);
else
    error('invalid number of arguments');
end


x = min( mx, max( mn, val ));
