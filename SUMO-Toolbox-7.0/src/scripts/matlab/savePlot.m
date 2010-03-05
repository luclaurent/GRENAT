function savePlot( handle, basefilename, formats )

% savePlot (SUMO)
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
%	savePlot( handle, basefilename, formats )
%
% Description:

	% Save fig unmodified, once it is expanded it is hard to modify again
	saveas( handle, [basefilename '.fig'] );

	% Expand axis
	style = hgexport('factorystyle');
	style.Bounds = 'tight';
	hgexport(handle,basefilename,style,'applystyle', true);
	drawnow;

	if exist( 'formats', 'var' )
		for i=1:length(formats)
			saveas( handle, [basefilename '.' formats{i}], formats{i} );
		end
	else
		% Save as eps,png
		saveas( handle, [basefilename '.png'] );
		saveas( handle, [basefilename '.eps'], 'epsc2' );
	end
end
