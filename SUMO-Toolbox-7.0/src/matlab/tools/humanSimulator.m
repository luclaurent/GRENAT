function out = humanSimulator(varargin)

% humanSimulator (SUMO)
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
%	out = humanSimulator(varargin)
%
% Description:
%	An interactive simulator that asks for responses interactively

in = [varargin{:}];

disp('===============================================');
disp('=== Starting HumanSimulator');
disp('===============================================');
disp(' ');
disp(sprintf('** The SUMO Toolbox is requesting %d points:', + size(in,1)));

in

disp(sprintf('** Please enter the simulator outputs. If there are multiple outputs, numbers should be space separated.\nComplex numbers should be specified as two (real/imag).\nType RESTART to start again.'));
disp(' ');

disp('===============================================');

out = [];
i = 1;
while(i <= size(in,1))
	line = input(sprintf('* Enter the output(s) for point %s (type RESTART to start again): ',arr2str(in(i,:))),'s');
	
	if(strcmp(line,'RESTART'))
		out = [];
		i = 1;
        disp('  RESTARTING....');
	end
	
	try
		tmp = str2num(line);
		out = [out ; tmp];
		i = i + 1;
		disp(sprintf('	-> read output(s) %s',arr2str(tmp)));
		
		if(i > size(in,1))
			disp(sprintf(' ==> %d points read : '));
			points = [in out]
			reply = input('Is the above correct? If so type yes, else type RESTART : ','s');

			if(strcmp(reply,'yes'))
				% do nothing
			else
				out = [];
				i = 1;
                disp('  RESTARTING....');
			end
		end
	catch ME
		disp(sprintf('Failed to read outputs: %s, please restart..',ME.message))
		out = [];
		i = 1;
        disp('  RESTARTING....');
	end
end

disp('===============================================');
