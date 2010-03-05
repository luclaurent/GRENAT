function [samplesT, T, Tinv] = eliminate_constraints( samples, A, b )

% eliminate_constraints (SUMO)
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
%	[samplesT, T, Tinv] = eliminate_constraints( samples, A, b )
%
% Description:

% in: samples (zonder outputs!), constraints van de vorm A*x = b (standaard
% matlab notatie
% out: getransformeerde samples en transformatiematrix

D = size( samples, 2); % dimension
T = eye(D+1); % D + homogene

% constraints zijn vast 
for i=1:size( A, 1 )

	n = A(i,:);
	normn = norm(n);
	n = n ./ normn;

	p1 = (b(i) ./ normn) .* n;
	p2 = p1 + n;

	% construct homogenous versions
	p1plus = [p1 1]';
	p2plus = [p2 1]';

	% Rotate space
	a = D - (i-1);

	for j=1:a-1
		nplus = T*[(p2-p1) 1]';
		
		theta = atan2( nplus(j), nplus(a) );
		T = buildRotationMatrix(theta, j, a) * T;
		Tinv = T * buildRotationMatrix(-theta, j, a);
	end

end

% Translate Space
%{
i = 1; % only 1 constraint

a = D - (i-1)

Tp1plus = T * p1plus
Tp2plus = T * p2plus
n = Tp2plus - Tp1plus
q = dot(Tp1plus, n) * n;
if q(a) ~= 0
	T(a, D) = -(norm(q)) ./ q(a)
end
%}

% transform samples
samplesT = zeros( size(samples) );
for i=1:size(samples,1)
	newsample = T*[samples(i,1:5) 1]';
	samplesT(i,1:5) = newsample(1:5,1)';
end

function mtx = buildRotationMatrix( angle, idx1, idx2 )
	mtx = eye(D+1);
	
	mtx(idx1, idx1 ) = cos(angle);
	mtx(idx2, idx1 ) = sin(angle);	

	mtx(idx1, idx2 ) = -sin(angle);
	mtx(idx2, idx2 ) = cos(angle);	
end

end
