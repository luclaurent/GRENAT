function [m, newModel, score] = calculateMeasure(m, model, context, outputIndex)

% calculateMeasure (SUMO)
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
%	[m, newModel, score] = calculateMeasure(m, model, context, outputIndex)
%
% Description:
%	Calculates the deviation from a linear fit

newModel = model;

samples = getSamplesInModelSpace(model);
values = getValues(model);
values = values(:,outputIndex);

dim_in = size(samples,2);
dim_out = size(values,2);

if(size(samples,2) > 4 && size(samples,1) > 1500)
    m.logger.warning('The LRMMeasure can become slow to use for more than 4 dimensions and more than 1500 samples')
end

try
    if(~isempty(context))
        % get the triangulation
        to = context.triangulation;
        T = to.getTriangulation();
        
        % take into account failed samples
        [failedSamples failedIdx] = to.getFailedPoints();
        failedValues = model.evaluateInModelSpace( failedSamples );
        
        samples = [samples ; failedSamples];
        values = [values ; failedValues(:,outputIndex)];
    else
        % build our own triangulation
        triobj = Triangulation(samples);
        T = triobj.getTriangulation();
    end
catch err
    % Sometimes, with a few points, the triangulation may fail.  But after
    % more points arrive the triangulation will work again.  Therefore dont
    % crash but return a score of one.
    m.logger.warning('Triangulation failed, LRM returning score of 1');
    score = ones(1,length(outputIndex));
    return
end

pointList = cell(size(T,1),1);
coeffList = cell(size(T,1),1);

%for every convex hull (line, triangle, tetraeder, ...)
for i=1:size(T,1)
    %get the points of the hull
    p = samples(T(i,:), :);
    
    % get the values corresponding to the points of the hull
    v = values(T(i,:), :);
    
    % fit a hyperplane through the [points values] for EVERY output j
    
    coeff = zeros( dim_in+2, dim_out );
    for j=1:dim_out
        
        % setup matrix for this output
        A = [p v(:,j) ones( size(p,1), 1)];
        [M,N] = size(A);
        
        % Calculate hyperplane coefficients for output k
        sign_coeff = 1;
        for k=1:N
            idx = [1:k-1 k+1:N];
            coeff(k,j) = sign_coeff .* det(A(:,idx));
            sign_coeff = -sign_coeff;
        end
    end
    
    % get the centroid in cartesian coorods
    %centroid = mean(p,1);
    centroid = sum(p,1) / size(p,1);  % avoiding mean is faster
    
    % centroid in barycentric coordinates (normalized)
    centroidBary = ones( 1, M ) ./ M;
    
    % the corner points in barycentric coordinates
    cornerBary = eye(M);
    
    % the corner points in cartesian coordinates
    cornerCart = p;
    
    % get the points halfway the centroid and the cornerpoints
    midMedianBary = ((ones(M,1)*centroidBary) + cornerBary) ./ 2; % this is faster than repmat
    
    % for higher dimensions, create more test points
    if(dim_in > 4)
        % get the middle of each simplex edge
        I = nchoosek(1:M,2);
        edgeMidBary = (cornerBary(I(:,1),:) + cornerBary(I(:,2),:)) ./ 2;
        
        % get the points halfway between the centroid and the edge midpoints
        edgeMidCentroidMidBary = ((ones(size(edgeMidBary,1),1)*centroidBary) + edgeMidBary) ./ 2;
        
        % the cartesian coordinates of the test points
        tp = [ edgeMidBary ; edgeMidCentroidMidBary ; midMedianBary ] * cornerCart;
        
    else
        % the cartesian coordinates of the test points
        tp = [midMedianBary] * cornerCart;
    end
    
    % All the points we want for this simplex
    points = [centroid ; tp];
    
    %{
    input('...')
    pause;
    if(dim_in == 2)
        hold off;
        plot3(A(:,1),A(:,2),A(:,3),'ro')
        grid = makeEvalGrid({-1:0.2:1, -1:0.2:1});
        res = -(coeff(1) .* grid(:,1) + coeff(2) .* grid(:,2) + coeff(4)) ./ coeff(3);
        hold on
        plot3(grid(:,1),grid(:,2),res,'b.')
        triplot(T(i,:), samples(:,1),samples(:,2));
        hold on
        plot(cornerCart(:,1),cornerCart(:,2),'bo')
        plot(centroid(:,1),centroid(:,2),'b+')
        plot(tp(:,1),tp(:,2),'g*')
        hold off
    elseif(dim_in == 3)
        tetramesh( T(i,:), samples );
        hold on
        plot3(cornerCart(:,1),cornerCart(:,2),cornerCart(:,3),'ro')
        plot3(centroid(:,1),centroid(:,2),centroid(:,3),'r+')
        plot3(tp(:,1),tp(:,2),tp(:,3),'r*')
        hold off
    end
    input('...')
    pause;
    %}
    
    % Store all the points (and the coefficients of the hyperplane they
    % define)
    pointList{i} = points;
    coeffList{i} = coeff;
end

% convert to a matrix
pts = cell2mat(pointList);

%{
input('...')
pause;
if(dim_in == 2)
    hold off;
    triplot(T, samples(:,1),samples(:,2));
    hold on
    plot(pts(:,1),pts(:,2),'g*')
    hold off
elseif(dim_in == 3)
    hold off;
    tetramesh(T, samples);
    hold on
    plot3(pts(:,1),pts(:,2),pts(:,3),'r*')
    hold off
end
input('...')
pause;
%}

% Evaluate the model at the points, dont do this inside the main for loop
% since that makes everything VERY slow
% However, since pointList can contain lots of points (> 600000) to save memory
% we evaluate the model in blocks
res = evaluateInModelSpaceBatch( model, pts, outputIndex, m.blockSize );

% number of test points for one simplex
numTp = size(pointList{1},1);

% now we have all the points, calculate the distance
dtot = zeros(1,length(outputIndex));
j=1;
for i=1:size(T,1)
    
    coeff = coeffList{i};
    
    % distance of the evaluated centroid to the plane
    for k=1:dim_out
        
        % get coefficients and evaluated values for output k
        coeff_mat = ones(numTp,1) * coeff(:,k)';
        fpoints = [pointList{i} res(j:j+numTp-1,k)];
        
        % Distance point-plane formula
        d = abs( sum(coeff_mat(:,1:N-1) .* fpoints, 2) + coeff_mat(:,N)) ./ sqrt(sum(coeff(1:end-1) .^ 2));
        
        % add the mean of the distances for each simplex
        dtot(:,k) = (sum(d,1) ./ numTp) + dtot(:,k);
    end
    
    j=j+numTp;
end

% take the average
score = dtot/size(T,1);

