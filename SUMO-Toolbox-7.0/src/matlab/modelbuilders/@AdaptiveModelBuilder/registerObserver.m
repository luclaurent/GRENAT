function s = registerObserver( s, tag, x_name, description, observables );

% registerObserver (SUMO)
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
%	s = registerObserver( s, tag, x_name, description, observables );
%
% Description:
%	Register a new observable and its corresponding profiler

import ibbt.sumo.profiler.*

if(~isfield(s.obsProfilers,tag))
	  s.obsProfilers.(tag) = {};
end
	
for k=1:length(observables)
	cols = getColumns( observables{k} );
	profname = sprintf( '%s_%s_%s', tag, getName( observables{k} ), s.profilerID );
	profname = ProfilerManager.makeUniqueProfilerName(profname);
	profiler = ProfilerManager.getProfiler( profname );
	profiler.setDescription( description );
	profiler.addColumn( x_name, x_name );
	  
	for c=1:length(cols)
	  profiler.addColumn( cols(c).name, cols(c).description );
	end	

	% there is no need for adding an observable if the corresponding profiler is not enabled
	if(profiler.isEnabled())
	  s.obsProfilers.(tag){end+1} =  struct( ...
					  'profiler', profiler, ...
					  'observable', observables{k} ...
					);
	end
end
