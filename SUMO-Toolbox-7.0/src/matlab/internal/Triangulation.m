classdef Triangulation < handle

% Triangulation (SUMO)
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
%	Triangulation(points)
%	getTriangulation(obj)
%	function  plotTriangulation(obj)
%
% Description:
%	A handle class that holds and updates a triangulation

	properties (SetAccess = private,GetAccess = private)
		T = [];
		points = [];
		failedPointsIdx = [];
        centers = [];
        volumes = [];
		modified = true;
	end
	
	methods (Access=public)
		function t = Triangulation(points)
			t.points = points;
			t.modified = true;
		end 

		function setPoints(obj,points,failedPoints)
			obj.points = [points ; failedPoints];
			obj.failedPointsIdx = size(points,1) + 1:size(failedPoints,1);
			obj.modified = true;
		end
		
		function [failedPoints idx] = getFailedPoints(obj)
			failedPoints = obj.points(obj.failedPointsIdx,:);
			idx = obj.failedPointsIdx;
		end
	
		function [T centers volumes] = getTriangulation(obj)
			if(obj.modified)
				obj = obj.update();
			else
				% do nothing
			end
			
			T = obj.T;
            centers = obj.centers;
            volumes = obj.volumes;
        end

        function pointList = generateTestPoints(obj)
            pointList = cell(size(obj.T,1),1);
            
            % re-generate delaunay diagram
            if obj.modified
				obj = obj.update();
            end
            
            %for every convex hull (line, triangle, tetraeder, ...)
            M = size(obj.T, 2);
            
            for i=1:size(obj.T,1)
                %get the points of the hull
                p = obj.points(obj.T(i,:), :);

                % get the centroid in cartesian coorods
                %centroid = mean(p,1);  
                centroid = sum(p,1) / size(p,1);  % avoiding mean is faster
                % centroid in barycentric coordinates
                cb = ones( 1, M ) ./ M;
                % the corner points in barycentric coords
                cpb = eye(M);
                % the M points we want (the halfway points in barycentric coords)
                % hb = (repmat( cb, M, 1) + cpb)./2;
                hb = ((ones(M,1)*cb) + cpb)./2; % this is faster than repmat
                % the cartesian coordinates of the corner points
                cpc = p;

                % the halfway points in cartesian coords	
                hc = hb*cpc;

                % All the points we want for this hull
                points = [centroid ; hc];

                % Store all the points (and the coefficients of the hyperplane they
                % define)
                pointList{i} = points;
            end
		end
		
		function  plotTriangulation(obj)
			if(obj.modified)
				obj = obj.update();
			end
			
			if size( obj.points, 2 ) == 2
				triplot( obj.T, obj.points(:,1),obj.points(:,2));
			end
		end
	end

	methods (Access=private)
		function obj = update(obj) 
			dim = size(obj.points,2);
			
			% Options of Delaunay
			% Qt triangulate
			% Qbb scale the last coordinate to [0,m] for Delaunay
			% Qc keep coplanar points with nearest facet 
			% Qx exact pre-merges (allows coplanar facets) 
			% IMPORTANT:
            % Qz add a point-at-infinity for Delaunay triangulations
			%    Option 'Qz' adds a point above the paraboloid of lifted
			%    sites for a Delaunay triangulation. It allows the Delaunay triangulation of cospherical sites. It reduces precision errors for nearly cospherical sites.
			
			switch dim
			case 2,
				obj.T = delaunay(obj.points(:,1),obj.points(:,2), {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
			case 3,
				obj.T = delaunay3(obj.points(:,1),obj.points(:,2),obj.points(:,3), {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
			otherwise
				obj.T = delaunayn(obj.points, {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
			end
            
            %% Update some useful variables
            % Centers of simplices
            obj.centers = obj.points(obj.T(:,1),:);
            for k=2:(dim+1)
                obj.centers = obj.centers + obj.points(obj.T(:,k),:);
            end
            obj.centers = obj.centers ./ (dim+1);
			
            % volumes of simplices
            nTriangles = size(obj.T,1);
            obj.volumes = zeros(nTriangles,1);
            for k=1:nTriangles
                obj.volumes(k) = abs( det( obj.points(obj.T(k,2:end),:) - obj.points(obj.T(k,1:end-1),:) ) );
            end
            obj.volumes = obj.volumes / factorial(dim);

            % All done
			obj.modified = false;
		end
	end

end
