function [scores xl yl extrema pf]= plotModelParetoFront( args, types, xl, yl, logScale )

% plotModelParetoFront (SUMO)
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
%	[scores xl yl extrema pf]= plotModelParetoFront( args, types, xl, yl, logScale )
%
% Description:
%	Plot the paretofront of the saved best model trace
%	There are different ways to call this function but the most straightforward way is:
%
%	plotModelParetoFront('/path/to/paretoFront-directory')

if(~exist('logScale','var'))
	logScale = [1 1];
else
    if(length(logScale)==1)
        logScale = repmat(logScale,1,2);
    end
end

if(~exist('xl','var'))
    xl = [];
end

if(~exist('yl','var'))
    yl = [];
end


% which model types are included in the pareto front (used in the
% heterogenetic case)
if(~exist('types','var'))
    types = [];
    typeShapes = {'b+'};
else
    %assign a plotting symbol for each type
    shapes = {'b+','g.','rs','co','mx','k*','bd','gv'};
    typeShapes = {};
    for i=1:length(types)
        typeShapes{i} = shapes{mod(i,length(shapes))+1};
    end
end

if(isa(args,'char'))
    % load a directory of pareto fronts
    if(isdir(args))
        pf = {};
        pfs = dir([args '/*.mat']);
        for i=1:length(pfs)
	    fname = [args '/' pfs(i).name];
            tmp = load(fname);
            tmp = tmp.pf;

            % cell array of models
            if(iscell(tmp))
                pf = [pf ; tmp];

            % array of models
            elseif(isa(tmp,'Model'))
                for(j=1:length(tmp))
                    pf = [pf {tmp(j)}];
                end
            elseif(isa(tmp,'struct'))
                disp('Failed to load the models, trying with struct')
                for(j=1:length(tmp))
                    pf = [pf {tmp(j).Model}];
                end
            else
                error('Invalid type');
            end
            
        end
    else
        % load a single pareto front file
        pf = load(args);
		pf = pf.pf;
		
		if(isa(pf,'cell'))
            % do nothing
        elseif(isa(pf,'Model'))
            pf = mat2cell(pf,1,ones(1,length(pf)));
        elseif(isa(pf,'struct'))
            disp('Failed to load the models, trying with struct')
            tmp = [];
            for(j=1:length(pf))
               tmp = [tmp {pf(j).Model}];
            end
            pf = tmp;
        else
           error('Invalid type');
        end
		
    end
else
	%do nothing, assume a cell of models
    pf = args;
end

disp(sprintf('%d models loaded from the pareto front',length(pf)))

% get the first model
m = pf{1};
numSamples = size(getSamples(m),1);
[indim, outdim] = getDimensions(m);
names = getOutputNames(m);

if(outdim == 1)
	% get the number of measures
	md = getMeasureScores(m);
	md = md.measureInfo;
	if(length(md{1}) < 2)
		% TODO we dont check if they are on
		error('Model must have 2 outputs or one output with 2 measures')
	else
		% one output, 2 measures, ok
	end
elseif(outdim == 2)
	% two outputs
else
	error('Only works if the models involved have 2 outputs');
end

scores = zeros(length(pf),2);

for i=1:length(pf)
	m = pf{i};
	if(isstruct(m))
		m = m.Model;
    else
        % do nothing
    end
    
	mdata = getMeasureScores(m);
    info = mdata.measureInfo;

	if(outdim == 2)
		% get the score for each output (assuming one measure per output)
		scores(i,:) = [info{1}{1}.score info{2}{1}.score];
    elseif(outdim == 1)
		% get the score for each measure
		scores(i,:) = [info{1}{1}.score info{1}{2}.score];
	else
		error('Invalid output dimension')
	end
	
    if(~isempty(types))
        % find the matching type so we can set the right line style
        t = class(m);
        
%          if(isa(m,'EnsembleModel'))
%              getDescription(m)
%          end
        
        for j=1:length(types)
            if(strfind(t,types{j}))
                break
            end
        end
    
        plot(scores(i,1),scores(i,2),typeShapes{j})
        hold on
    else
        plot(scores(:,1),scores(:,2),'b+')
    end
end

hold off

if(~isempty(types))
    legend(types,'FontSize',14,'Location','NorthEastOutside')
    
    % since Matlab cannot figure out which marker (color) fits which legend
    % entry, force it.
    for i=1:length(types)
        h = findobj(gcf,'DisplayName',types{i});
        sh = typeShapes{i};
        set(h,'Color', sh(1))
        set(h,'Marker',sh(2))
    end
end

if(outdim == 2)
	xlabel([info{1}{1}.type ' score on ' names{1} ' (' info{1}{1}.errorFcn ')'],'FontSize',14)
	ylabel([info{2}{1}.type ' score on ' names{2} ' (' info{2}{1}.errorFcn ')'],'FontSize',14)
elseif(outdim == 1)
	xlabel([info{1}{1}.type ' score on ' names{1} ' (' info{1}{1}.errorFcn ')'],'FontSize',14)
	ylabel([info{1}{2}.type ' score on ' names{1} ' (' info{1}{2}.errorFcn ')'],'FontSize',14)
else
	error('Invalid output dimension')
end

if(logScale(1))
    set(gca,'XScale', 'log')
end
if(logScale(2))
    set(gca,'YScale', 'log')
end

title(sprintf('First model built with %d samples',numSamples),'FontSize',14)

if(~isempty(xl))
    xlim(xl);
else
    xl = xlim();
end

if(~isempty(yl))
    ylim(yl);
else
    yl = ylim();
end

set(gca,'FontSize',14);

drawnow


% perform a non dominated sort to find the first front
%disp('Performing non dominated sort')
% TODO karels code does not produce correct results???
%[index, dominance, distance] = nonDominatedSort(scores);
% plot the first front (is the one with dominance 0)
%I = find(dominance < 1);
%idx = index(I);
%idx = paretofront(scores);
%hold on
%plot(scores(idx,1),scores(idx,2),'rs','MarkerFaceColor','r','MarkerSize',10);
%hold off

print(gcf,'paretoTrace.fig')

% get the models representing the endpoints of the front
[Y I] = min(scores,[],1);
extrema{1} = pf{I(1)};
extrema{2} = pf{I(2)};
