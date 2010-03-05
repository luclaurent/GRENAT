function centroid = largestTriangleCentre( x, y, lb, ub )

% largestTriangleCentre (SUMO)
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
%	centroid = largestTriangleCentre( x, y, lb, ub )
%
% Description:
%	Return the centre of the largest triangle of the delaunay diagram over the 2D points
%	x,y whose ranges lie within given lower and upper bounds (eg: lb = [lowerbound for x, lowerbound for y])

if(length(x) ~= length(y))
	error('Point vectors must have the same length');
end

if(length(lb) ~= length(ub))
	error('Bounds vectors must have the same length');
end

if(length(x) == 0)
	if(length(lb) > 0)
		centroid = [(lb(1) + ub(1)) / 2, (lb(2) + ub(2)) / 2];
		return;
	else
		error('Must specify datapoints and/or bounds');
	end
end

if(length(lb) > 0)
	% add the corner points
	corners = makeEvalGridInverted({[lb(1) ub(1)],[lb(2) ub(2)]});
	x = [x ; corners(:,1)];
	y = [y ; corners(:,2)];
end


% triangulate
try
	T = delaunay(x,y);
catch
	%qhull may crash if the triangles are too small or the points are colinear
	%return a random point
	centroid = boundedRand(lb , ub);
	return
end

maxTrisize = 0;
centroid = 0;

%for every triangle
for i=1:size(T,1)
	%get the triangle coordinates
	p1 = [x(T(i,1)) y(T(i,1)) 0];
	p2 = [x(T(i,2)) y(T(i,2)) 0];
	p3 = [x(T(i,3)) y(T(i,3)) 0];

	%calculate the area of each triangle
	area = abs(norm(cross(p2-p1,p3-p1))*0.5);

	if (area > maxTrisize)
		%calculate the centroid
		centroid = [mean([p1(1,1) p2(1,1) p3(1,1)]), mean([p1(1,2) p2(1,2) p3(1,2)])];
		maxTrisize = area;
	end
end

%figure
%triplot(T,x,y)
%hold on
%plot(centroid(1),centroid(2),'r+');
%hold off
