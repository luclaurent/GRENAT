function s = observe(s, tag, x_value, object)

% observe (SUMO)
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
%	s = observe(s, tag, x_value, object)
%
% Description:
%	Observe each observable and record the values in the matching profilers

% Get the list for the corresponding tag (e.g, those starting with 'best')
plist = s.obsProfilers.(tag);

for i = 1:length(plist)
	obs = plist{i};

    % If the observable is incompatible with the given type the returned data is an empty array
	data = process(obs.observable, object);
    if(~isempty(data))
        %sprintf('Updating %s',char(obs.profiler.getName()))
        profiler = obs.profiler;
        
        if ischar( data ) || iscell( data )
            profiler.addEntry( x_value, data );
        else
            profiler.addEntry( [ x_value data(:).' ] );
        end
    end
end
