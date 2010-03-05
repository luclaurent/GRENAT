function plotColumns(varargin);

% plotColumns (SUMO)
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
%	plotColumns(varargin);
%
% Description:
%	plotColumns(Y): create a line plot for each column of Y, use the first column as x values
%	plotColumns(X,Y): same as above, except use the X column vector as x values
%	plotColumns(X,Y,xlabel,ylabel,labels): same as above, except use the given axis and legend labels
%	plotColumns(X,Y,E): calls errorbar
%	plotColumns(X,Y,E,xlabel,ylabel,labels): same as above, except use the given axis and legend labels

if(nargin == 1)
	Y = varargin{1};
	X = Y(:,1);
	Y = Y(:,2:end);
	E = [];
	labels = {};
	xl = 'x';
	yl = 'y';
elseif(nargin == 2)
	X = varargin{1};
	Y = varargin{2};
	E = [];
	labels = {};
	xl = 'x';
	yl = 'y';
elseif(nargin == 3)
	X = varargin{1};
	Y = varargin{2};
	E = varargin{3};
	labels = {};
	xl = 'x';
	yl = 'y';
elseif(nargin == 5)
	X = varargin{1};
	Y = varargin{2};
	E = [];
	xl = varargin{3};
	yl = varargin{4};
	labels = varargin{5};
elseif(nargin == 6)
	X = varargin{1};
	Y = varargin{2};
	E = varargin{3};
	xl = varargin{4};
	yl = varargin{5};
	labels = varargin{6};
else
	error('Invalid number of arguments given');
end

%create the default labels
if(length(labels) < 1)
	for i=1:size(Y,2)
		labels{i} = num2str(i);
	end
end

%Create all possible line styles
shapeGrid = buildShapeGrid();
nShapes = length(shapeGrid);

% line plot
for i=1:size(Y,2)
	%build the line style
	si = mod(i,nShapes)+1;
	shape = shapeGrid{si};

	if(length(E) > 0)
		errorbar(X,Y(:,i),E,shape);
	else
		plot(X,Y(:,i),shape);
	end
	hold on
end
hold off;

xlabel(xl,'FontSize',14,'interpreter','none');
ylabel(yl,'FontSize',14,'interpreter','none');
legend(labels,'FontSize',14,'Location','NorthEastOutside','interpreter','none');

set(gca,'FontSize',14);
if(isLargeScale(Y))
	set(gca,'YScale','log');
end


	%Is the scale difference so large shat we should plot using a log scale?
	function res = isLargeScale(Y)
		diff = abs(log10(max(max(Y)) - log10(min(min(Y)))));
		if(diff > 3)
			res = true;
		else
			res = false;
		end
	end

end
