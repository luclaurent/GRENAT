function fighandle = basicPlotModel(varargin)

% basicPlotModel (SUMO)
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
%	fighandle = basicPlotModel(varargin)
%
% Description:
%	This is a basic/default implementation called by plotModel.m, if subclasses
%	want more fancy features they should override plotModel and not basicPlotModel

defaults = Model.getPlotDefaults();

if(nargin == 1)
    model = varargin{1};
    outputIndex = 1;
    options = defaults;
elseif(nargin == 2)
    model = varargin{1};
    outputIndex = varargin{2};
    options = defaults;
elseif(nargin == 3)
    model = varargin{1};
    outputIndex = varargin{2};
    options = mergeStruct(defaults, varargin{3});
else
    error('Invalid parameters given');
end

% global figure handle, one figure for each output
global modelPlotFigure;

% get the samples and values in simulator space
samples = getSamples(model);
vals = getValues(model);

% get the dimensions
[inDim outDim] = getDimensions(model);

% check the output index is ok
if(isempty(outputIndex))
    outputIndex = 1;
end

if(outputIndex > outDim)
    error(sprintf('Cannot access output %d since the model has only %d outputs',outputIndex,outDim));
end

%Ensure the outputIndex is not out of bounds
if((outputIndex < 1) || (outputIndex > size(vals,2)))
    error(sprintf('Error, outputIndex (%d) exceeds number of outputs (%d)',outputIndex,size(vals,2)));
end

% get the input names
axisLabels = getInputNames(model);

% Get the input bounds
[minRange maxRange] = model.getBounds();;

% get the output names
on = getOutputNames(model);
outputName = on{outputIndex};
origOutputName = outputName;
%remove spaces and other illegal chars
outputName = makeValidMatlabIdentifier(outputName);

surfaceColor = options.color;
contourOn = options.withContour;
plotContourOn = options.plotContour;
samplesOn = options.plotPoints;
% alpha value for uncertainty bounds
alphaVal = options.alphaVal;
steps = options.meshSize;
slices = options.slices;

if options.newFigure
    modelPlotFigure.(outputName) = figure;
elseif ~isfield(modelPlotFigure,outputName)
    modelPlotFigure.(outputName) = figure;
else
    figure(modelPlotFigure.(outputName));
end

% no bounds set in the options, set them!
if isempty(options.bounds)
    options.bounds = [minRange' maxRange'];
end

% Adjust size and position
% Get screen and default figure size
screenSize = get(0,'screensize');
screenSize = screenSize([3 4]);
figureSize = get(gcf,'Position');
figureSize = figureSize([3 4]);
% Adjust figure size in case of dim > 3
if(inDim > 3)
    if inDim == 4
        figureSize(1) = figureSize(1)*3;
    elseif inDim > 4
        figureSize = figureSize*3;
    end
    %When the file is saved, use the screen size, not the default size
    set(gcf,'paperpositionmode','auto');
    
    % Set size and center window
    %newPosition = [ screenSize/2 - figureSize/2 , figureSize ];
    %set( gcf, 'Position', newPosition );
end

%TODO: not sure why this would be needed
clf

%Plot title
plotTitle = sprintf('Plot of %s using %s\n(built with %d samples)',origOutputName, class(model), size(samples,1));


% precalculate some stuff that is used for > 1D cases
if inDim > 1
    x1 = linspace(options.bounds(1,1),options.bounds(1,2),steps) .';
    x2 = linspace(options.bounds(2,1), options.bounds(2,2),steps) .';
    [x1g,x2g] = meshgrid( x1,x2 );
end

% precalculate slices for the remaining variables
if inDim > 2
    xslices = zeros(inDim-2,slices);
    for i = 3 : inDim
        xslices(i-2,:) = linspace(options.bounds(i,1),options.bounds(i,2),slices);
    end
end


% create a utility struct for each dimension
if(inDim == 1)
    data = struct( ...
        'model', model, ...
        'x1label', axisLabels{1}, 'x2label', '', ...
        'zlabel', origOutputName, ...
        'title', plotTitle ...
        );
elseif(inDim == 2)
    data = struct( ...
        'model', model, ...
        'x1label', axisLabels{1}, 'x2label', axisLabels{2}, ...
        'zlabel', origOutputName, ...
        'title', plotTitle ...
        );
else
    data = struct( ...
        'model', model, ...
        'x1', x1g, 'x2', x2g, ...
        'x1label', axisLabels{1}, 'x2label', axisLabels{2}, ...
        'zlabel',  axisLabels{3},...
        'title', plotTitle ...
        );
end

switch inDim
    case 1
        x = linspace(options.bounds(1,1), options.bounds(1,2), steps) .';
        y = evaluate(model, x);
        y = y(:,outputIndex);
        plot(x,complexFix(y(:,1)));
        plotSamples(inDim,options,model,samples,vals,outputIndex);
        
        % also plot the uncertainty if needed
        if(options.plotUncertainty)
            yu = evaluateMSE(model,x);
            yu = yu(:,outputIndex);
            hold on;
            plot(x,y+yu,'k-.');
            plot(x,y-yu,'k-.');
            hold off;
        end
        
        title(plotTitle,'FontSize', options.fontSize,'interpreter','none');
        xlabel(data.x1label, 'FontSize', options.fontSize);
        ylabel(data.x2label, 'FontSize', options.fontSize);
        
    case 2
        outputs = evaluate(model, [x1g(:) x2g(:)]);
        outputs = outputs(:,outputIndex);
        y = complexFix(reshape(outputs, size(x1g)));
        
        % do we want a contour plot or a surface plot
        if plotContourOn
            % plot the model as a contour plot
            [C, h] = contourf(x1,x2,y);
            
			% dont plot extra contour labels in classification mode
            if(~strcmp(model.getMode(),'classification'))
                clabel(C, h);
            end
        else
            if contourOn
                if ~isempty(surfaceColor)
                    h = surfc(x1,x2,y, repmat(surfaceColor, size(y)));
                else
                    h = surfc(x1,x2,y);
                end
                
            else
                if ~isempty(surfaceColor)
                    h = surf(x1,x2,y,repmat(surfaceColor, size(y)));
                else
                    h = surf(x1,x2,y);
                end
            end
            
            % make sure this surf is opaque
            alpha(h,1);
            
            % plot the uncertainty
            if(options.plotUncertainty)
                yu = evaluateMSE(model, [x1g(:) x2g(:)]);
                yu = yu(:,outputIndex);
                yu = reshape(yu, size(x1g));
                hold on
                hu = surf(x1,x2,y+yu,'EdgeColor','none','FaceColor','interp');
                alpha(hu,alphaVal);
                hu = surf(x1,x2,y-yu,'EdgeColor','none','FaceColor','interp');
                alpha(hu,alphaVal);
                hold off;
            end
        end
        
		% finally plot the sample points
        plotSamples(inDim,options,model,samples,vals,outputIndex);

        title(plotTitle,'FontSize', options.fontSize,'interpreter','none');
        xlabel( data.x1label, 'FontSize', options.fontSize,'interpreter','none' );
        ylabel( data.x2label, 'FontSize', options.fontSize,'interpreter','none' );
        zlabel(data.zlabel, 'FontSize', options.fontSize,'interpreter','none' );
    case 3
        %subplot(sp(outputsToPlot,1),sp(outputsToPlot,2),k);
        slicePlot( data, xslices, [], outputIndex , options, axisLabels);
        
    case 4
        for k=1:slices
            set(gcf,'Clipping','on');
            subplot(1,slices,k);
            slicePlot( data, xslices(1,:), xslices(2,k), outputIndex, options, axisLabels);
        end
        
    otherwise
        trailer = zeros(1,inDim-5);
        for k=1:slices
            for l=1:slices
                subplot(slices,slices,(k-1)+slices*(l-1)+1);
                slicePlot( data, xslices(1,:), [xslices(2,k),xslices(3,l) trailer],outputIndex, options, axisLabels);
            end
        end
        
end

%Set the window title of the plot
set(gcf,'Name', origOutputName);

% Normalize the output ranges, so that each subplot has the same max/min on the z-axis
if(inDim > 1)
    % find the min/max z-axis values
    h = findobj(gcf,'-property','ZLim');
    zranges = zeros(length(h),2);
    
    for i=1:length(h)
        zranges(i,:) = zlim(h(i));
    end
    
    Zrange = [min(zranges(:,1)),max(zranges(:,2))];
    
    % Now set the maximum on all the other sub plots
    for i=1:length(h)
        zlim(h(i),Zrange);
    end
end

% get all axes
theAxes = findobj(gcf,'Type','axes');

%Clip the output range if an explicit range is specified
if(length(options.outputAxisRange) > 0)
    set(gcf,'Clipping','on');
    v = axis;
    axis(theAxes,[v(1) v(2) v(3) v(4) options.outputAxisRange(1) options.outputAxisRange(2)]);
end

for i=1:length(theAxes)
    %set the current axis
    set(gcf,'CurrentAxes',theAxes(i));
    
    if(options.lighting)
        % Add some fancy lighting
        light('Position',options.lightPos,'Style',options.lightStyle);
        lighting phong;
        shading interp;
    end
    
    if(options.logScale)
        if(inDim < 2)
            set(gca,'YScale','log');
        else
            set(gca,'ZScale','log');
        end
    end
end

if(options.grayScale)
    colormap(gray);
else
    colormap(jet);
end

% Remove surrounding whitespace
%tis = get(gca, 'TightInSet');
%pos = [tis(1:2) 1-(tis(1:2)+tis(3:end))];
%set( gca, 'Position', pos );

%Update plot
drawnow;

% return figure handle
fighandle = modelPlotFigure.(outputName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slicePlot( data, sliceCoords, fixedCoords, l, options, axisLabels )
slices = length(sliceCoords);

%Was grayscale specified in the plot options?
if(options.grayScale)
    %for black and white
    fc = { [1 1 1], [.5 .5 .5], [.9 .9 .9], [.3 .3 .3] , [.8 .8 .8], [.4 .4 .4]};
else
    % For color plots
    fc = { 'r', 'g', 'b', 'w' , 'y' , 'k'};
end

for k=1:slices
    
    others = [sliceCoords(k) fixedCoords];
    outputs = evaluate( data.model, ...
        [data.x1(:) data.x2(:) ...
        repmat( others, length(data.x1(:)), 1 )] );
    y = reshape( outputs(:,l), size( data.x1 ) );
    y = complexFix( y );
    hslice = surf( data.x1,data.x2,y );
    
    col = mod(k,length(fc));
    if(col == 0)
        col = length(fc);
    end
    
    set(hslice,'FaceColor',fc{col});
    set(hslice,'EdgeColor','k');
    hold on
end

xlabel( data.x1label, 'FontSize', options.fontSize,'interpreter','none' );
ylabel( data.x2label, 'FontSize', options.fontSize,'interpreter','none' );
zlabel( sprintf( '%d slices for %s', slices, data.zlabel), 'FontSize', options.fontSize, 'interpreter', 'none');
set(gca,'FontSize', options.fontSize );

%Construct the title
fixStr = {};
if(isempty(fixedCoords))
    fixStr = data.title;
else
    %As a title take "axisLabel=value" with 'rowlength' axisValues per row
    rowlength = 2;
    len = min(4,length(fixedCoords));
    i=1;
    while(i <= len)
        str = [axisLabels{i+3} '=' num2str(fixedCoords(i))];
        i = i + 1;
        j = 1;
        while(i <= len && j < rowlength)
            str = [str [', ' axisLabels{i+3} '=' num2str(fixedCoords(i))]];
            j = j + 1;
            i = i + 1;
        end
        
        fixStr = [fixStr str];
    end
    
    if length(fixedCoords) > 4
        fixStr{end} = [fixStr{end} ', ...'];
    end
end

title(fixStr,'FontSize',options.fontSize,'interpreter','none');
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the sample points on top of the model plot
function plotSamples(inDim, options, model, samples, vals, outputIndex)
    if(~options.plotPoints)
        return;
    end
    
    hold on;
    switch inDim
        case 1
            plot(samples(:,1), complexFix(vals(:,outputIndex)), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
        case 2
            if options.plotContour
				% contour plot
				if(strcmp(model.getMode(),'classification'))
					% classification
					if (license('test','statistics_toolbox'))
						% small hack to show a nice plot when dealing with classification, relies on the statistics toolbox
						gscatter(samples(:,1),samples(:,2),complexFix(vals(:,outputIndex)));
					else
						plot( samples(:,1), samples(:,2), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k' );
					end
				else
					% regression
					plot( samples(:,1), samples(:,2), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k' );
				end
			else
				% surface plot
				scatter3( samples(:,1), samples(:,2), complexFix(vals(:,outputIndex)), [], 'k', 'o', 'filled', 'MarkerEdgeColor', 'k');
			end
        otherwise
	end
    hold off;
	
