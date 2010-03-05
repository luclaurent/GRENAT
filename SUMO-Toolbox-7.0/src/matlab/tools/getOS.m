function platform = getOS()

% getOS (SUMO)
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
%	platform = getOS()
%
% Description:
%	find platform OS

if ispc
   platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
elseif strcmp(computer, 'MAC') == 1
    [fail, input] = unix('sw_vers');
    if ~fail
    platform = strrep(input, 'ProductName:', '');
    platform = strrep(platform, sprintf('\t'), '');
    platform = strrep(platform, sprintf('\n'), ' ');
    platform = strrep(platform, 'ProductVersion:', ' Version: ');
    platform = strrep(platform, 'BuildVersion:', 'Build: ');
    else
        platform = system_dependent('getos');
    end
else    
   platform = system_dependent('getos');
end
