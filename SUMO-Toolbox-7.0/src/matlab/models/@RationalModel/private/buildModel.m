function this = buildModel( this )

% buildModel (SUMO)
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
%	this = buildModel( this )
%
% Description:
%	Do interpolation/approximation of samples/values

samples = getSamplesInModelSpace(this);
values = getValues(this);

[inDim outDim] = getDimensions(this);

% Adjust frequency to complex samples -AND-
% Calculate how many degrees to use
if this.frequencyVariable ~= 0
	samples(:,this.frequencyVariable) = j * ( 2 + samples(:,this.frequencyVariable) );
	lsq_degrees = min( fix( this.percent * (2*size(samples,1)+1) / 100 ), 2*size( samples,1 ) );
else
	lsq_degrees = min( fix( this.percent * (size(samples,1)+1) / 100 ), size( samples,1 ) );
end

% ilm: it may be possible lsq_degrees is truncated to 0, make sure it it at
% least 1
if lsq_degrees < 1
	lsq_degrees = 1;
end

% Get degrees from degree manager
this.degrees = update( this.degrees, lsq_degrees );
[numdegrees,dendegrees] = getDegrees( this.degrees, lsq_degrees );

% Construct linear system
MN = buildVandermondeMatrix( samples, numdegrees, this.baseFunctions );
MD = buildVandermondeMatrix( samples, dendegrees, this.baseFunctions );

numerator = cell( inDim, 1 );
denominator = cell( outDim, 1 );

for k=1:outDim
	val = values(:,k);
	F = diag( val );
	
	% Construct interpolation system
	M = [ MN (-F * MD) ];
	
	if this.weighted
	%  	disp( '[W] WEIGHTED' );
		% Construct Weights
		W = diag( 1 ./ (1 + abs(val)) );	
		M = W*M;
		val = W*val;
	end
	
	% split system in real and imaginary parts
	if this.frequencyVariable ~= 0
	%    	disp( '[W] FREQUENCY VAR' );
		M = [real(M) ; imag(M)];
		val = [real(val) ; imag(val)];
	end
	
	% Solve system and split into numerator and denominator part
	% ILM: use lscov so we can retrieve some extra information about the
	% result
	%coeff = M \ val;
	
	[coeff, stdx,mse,S] = lscov( M, val );
	this.covarianceMatrix{k} = S; % S ./ mse;  % inv(M.'*M);
	
	num = coeff(1:size(numdegrees,1));
	den = coeff((size(numdegrees,1)+1):end);
	
	if (size(num,2) == 0), num = zeros(0,1); end
	if (size(den,2) == 0), den = zeros(0,1); end
	
	numerator{k} = num;
	denominator{k} = den;
end

this.numerator = numerator;
this.denominator = denominator;
this.freedom = lsq_degrees;
