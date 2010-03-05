function res = inModel(varargin)

% inModel (SUMO)
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
%	res = inModel(varargin)
%
% Description:

  if (nargin == 1)
    pts = varargin{1};
    x = pts(:,1);
    y = pts(:,2);
    z = pts(:,3);
  elseif (nargin == 2)
    pts = varargin{1};
    x = pts(:,1);
    y = pts(:,2);
    z = pts(:,3);
    options = varargin{2};
  elseif (nargin == 3)
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
  elseif (nargin == 4)
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    options = varargin{4};
  else
    error('Invalid number of arguments');
  end

  if(~exist('options','var'))
    file = 'SphereSurface.mat';
  else
    file = options{2};
  end

  % get the directory of this file
  dir = mfilename('fullpath');
  p = fileparts(dir);

  global modelSurfaceData;

  % prevent from loading full mesh every time
  if(isempty(modelSurfaceData))
    modelSurfaceData = load(fullfile(p,file));
  else
    % data already loaded
  end
  % inside is 1, outside is -1
  inside=InPolyedron(modelSurfaceData.p,modelSurfaceData.t,modelSurfaceData.tnorm,[x y z])*2-1;
  
  res = [x y z inside];  
end
