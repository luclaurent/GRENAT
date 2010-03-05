function [totalResult totalBestIndex] = bruteForceModelSearch(filenameFull, sampleInc)

% bruteForceModelSearch (SUMO)
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
%	[totalResult totalBestIndex] = bruteForceModelSearch(filenameFull, sampleInc)
%
% Description:
%	Does a brute force search of the model parameter space.  Supports
%	different model types and also supports sampling (multiple brute
%	force runs for each number of samples)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Which model type: Kriging or SVM
modelType = 'SVM';
params = {'spread','c'};
%modelType = 'Kriging';
%params = {'theta1','theta2'};
% number of inputs
inDim = 3;
% number of outputs
outDim = 1;
% which output (can be a vector)
trainOutputIndex = [1];
testOutputIndex = [6];

%%%% training data, can be a path to a dataset or a function handle

%trainingData = 'MOTestFunction1GridSmall.txt';
%trainingData = @MOTestFunction1 ; trGridSize = 30; bounds = [-1 1];
%trainingData = 'examples/Chemistry/ChemistryTrain.txt';
%trainingData = 'samples-copied.txt';
trainingData = 'samples.txt';
%trainingData = @lnaperf2 ; trGridSize = 12; bounds = [-1 1];

%%%% the testing data, can be a path to a dataset, a measure object, or a function handle
%testingData = 'MOTestFunction1Grid.txt';
%testingData = 'examples/Chemistry/ChemistryTest.txt';
testingData = 'examples/private/lna/lna3.txt';
%testingData = CrossValidation(nfolds, inDim);
%testingData = SmoothnessMeasure();
%testingData = @lnaperf2 ; teGridSize = 21; bounds = [-1 1];

% error function to use
errorFunction = 'rootRelativeSquareError';

% the hyperparameter searc grid
gridSize = { linspace(-5,5,21), linspace(-5,5,21) };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalResult = {};
totalBestIndex = {};

%%%% Load the training data
% if trainingData is a function handle we need to create a grid first
if(isa(trainingData,'function_handle'))
    trainDataFull = buildGrid(trainingData, inDim, bounds, trGridSize);
else
    % load the training data from file
    trainDataFull = unique(load(trainingData),'rows');
end

%%%% Load the testing data
if(isa(testingData,'Measure'))
    testData = setErrorFcn(testingData,errorFunction);
    disp(sprintf('%d by %d testing points constructed',size(testData,1),size(testData,2)))
elseif(isa(testingData,'function_handle'))
    testData = buildGrid(testingData, inDim, bounds, teGridSize);
    disp(sprintf('%d by %d testing points constructed',size(testData,1),size(testData,2)))
    errFun = eval(['@' errorFunction]);
else
    testData = unique(load(testingData),'rows');
    errFun = eval(['@' errorFunction]);
end

% if there is no sampling set the sample increment to the size of the
% trainingData
if(~exist('sampleInc','var'))
    sampleInc = size(trainDataFull,1);
end

if(~exist('filenameFull','var'))
    filenameFull = modelType;
end


si = 0;
% if sampleInc is set then we sample from the training data in the
% specified increments and do a brute force search for each increment.
% This allows us to see how the optimization surface changes if sampling
% is enabled
while(si < size(trainDataFull,1))
    trainData = [];
    si = si + sampleInc;
    si = min(si,size(trainDataFull,1));
    filename = sprintf('%s_%04d_samples.txt',filenameFull,si);
    trainData = [trainData ; trainDataFull(1:si,:)];
    
    % make the grid
    grid = makeEvalGrid( gridSize );
    n = size(grid,1);

    disp(sprintf('Doing a brute force search of %d points and training with points 1 to %d...',n,si))

    % open a file
    f = fopen(filename,'w');

    scores = zeros(n,length(trainOutputIndex));

    % loop over all points in the grid
    for i=1:n
        tic;
        p = grid(i,:);

        scores(i,:) = fitnessFun(p);

        entry = [p scores(i,:)];
        s = '';
        for k=1:length(entry)
            s = [s sprintf('%e\t',entry(k))];
        end

        %if(mod(i,1) == 0)
        disp( sprintf( 'Iteration %i of %i took %d seconds, entry: %s', i, n, toc, arr2str(entry) ) );
        %end

        % add to file
        fprintf(f,'%s\n',s);
    end

    fclose(f);

    result = [grid scores];
    [bestVal bestIndex] = min(scores,[],1)

    % do some post processing if 2D
    if(size(grid,2) == 2)
        % for every output
        for i=1:size(scores,2)
            % plot the optimization surface
            opt = plotScatteredData();
            opt.contour = 1;
            opt.colorbar = 1;
            opt.plotPoints = 0;
            opt.contourLines = 10;
            figure(i+1)
            plotScatteredData([grid log(scores(:,i))],opt);

            % plot the minimum
            hold on
            plot(grid(bestIndex(i),1),grid(bestIndex(i),2),'*k')
            hold off

            % add title and axis labels
            title({sprintf('%s Hyperparameter surface for output %d (%s)',modelType,i, errorFunction), sprintf('fmin(%s) = %d',arr2str(grid(bestIndex(i),:)), bestVal(i)), sprintf('Models built with %d samples',si)},'FontSize',14)
            xlabel(params{1},'FontSize',14);
            ylabel(params{2},'FontSize',14);

            % save the plot
            fname = [filename '_' modelType '_npoints=' num2str(n) '_output=' num2str(i)];
            saveas(gcf,[fname '_surface.fig'])
            saveas(gcf,[fname '_surface.png'])
            %print(gcf,[fname '_surface.eps'])
            close all

            % plot the model at the best location
            figure(i+2)
            [score m] = fitnessFun(grid(bestIndex(i),:));
            plotModel(m,i);
            saveas(gcf,[fname '_bestModel.fig'])
            saveas(gcf,[fname '_bestModel.png'])
            %print(gcf,[fname '_bestModel.eps'])
            close all
        end
    end
    totalResult = [totalResult result];
    totalBestIndex = [totalBestIndex bestIndex];
    % close all plots
    close all
end % end sampling loop

if(size(grid,2) == 2)
    % find the max/min of each brute force search so we can normalize the
    % plots (to prevent axis jumping)
    mn = repmat(Inf,1,length(trainOutputIndex));
    mx = repmat(-Inf,1,length(trainOutputIndex));

    for i=1:length(totalResult)
        r = totalResult{i};
        for k=1:length(trainOutputIndex)
            % remember to take the log
            mxr = max(log(r(:,2+k)));
            mnr = min(log(r(:,2+k)));
            if(mxr > mx(k))
                mx(k) = mxr;
            end
            
            if(mnr < mn(k))
                mn(k) = mnr;
            end
        end
    end
    
    % generate a movie of the surface evolution for each output
    for i=1:length(trainOutputIndex)
        % load each fig, normalize it and re-save it as png
        figs = dir(['*output=' num2str(i) '*surface*.fig']);
        for k=1:length(figs)
            h=hgload(figs(k).name);
            caxis([mn(i) mx(i)]);
            saveas(gcf,[figs(k).name(1:end-3) 'png']);
            close all
        end
        
        % generate the movie
        images2movie(['*output=' num2str(i) '*surface*png'],['movie_surface_output=' num2str(i) '.mov'],'',1);
    end
end
            
        function [score m] = fitnessFun(p)
            % Build the model for the given parameters
            m = eval(['build' modelType 'Model(p)']);
            % train the model
            m = construct( m, trainData(:,1:inDim), trainData(:,inDim + trainOutputIndex) );
            %plotModel(m)	
            % calculate the error
            if(isa(testData,'Measure'))
                if(length(testOutputIndex) > 1)
                    error('If you are using a measure you must select only one output')
                end

                [dummy, dummy2, score] = calculateMeasure(testData, m, [], testOutputIndex );
            else
                score = [];
                modelOut = evaluate(m,testData(:,1:inDim));

                for k=1:length(testOutputIndex)
                    score(k) = feval(errFun, testData(:,inDim + testOutputIndex(k)), modelOut(:,k));
                end
            end
        end

        function m = buildSVMModel(x)
            % SVMModel config
            config = struct(...
                'backend',		'lssvm',...
                'type',			'epsilon-SVR', ...
                'kernel',		'rbf', ...
                'kernelParams',		x(1), ...
                'regularizationParam',	x(2), ...
                'nu',			0.01, ...
                'epsilon',		1e-5, ...
                'stoppingTolerance',	1e-5, ...
                'crossvalidationFolds',	0, ...
                'extraParams',		'' ...
            );
            m = SVMModel(config);
        end

        function m = buildKrigingModel(x)
            m = KrigingModel(x,'regpoly1','corrgauss');
        end

        function res = buildGrid(h,dim,bounds,sz)
            grid = {};
            if(size(bounds,1) == 1)
                % use the same bounds for all dimensions
                bounds = repmat(bounds,dim,1);
            end
            
            grid = {};
            for jj=1:dim
                x = linspace(bounds(jj,1),bounds(jj,2),sz);
                grid = [grid x];
            end
            g = makeEvalGrid(grid);
            
            % now that we have the grid, evaluate it
            ni = nargin(h);
            no = nargout(h);
            
            % -1 means varargin
            if(ni == 1 || ni == -1)
                % pass as a matrix
                if(no == 1)
                    out = feval(h,g);
                elseif(no == 2)
                    [o1 o2] = feval(h,g);
                    out = [o1 o2];
                else
                   error('Unsupported output size'); 
                end
                    
            else
                % evaluate one by one
                out = zeros(size(grid,1),outDim);
                for jj=1:size(g,1)
                    if(ni == 2)
                        tmp = feval(h,g(jj,1),g(jj,2));
                    elseif(ni == 3)
                        tmp = feval(h,g(jj,1),g(jj,2),g(jj,3));
                    else
                        error('Unsupported input size');
                    end
                    out(jj,:) = tmp;
                end
            end
            res = [g out];
        end
    
end % end function
