function [N,D] = getDegrees(s, n)

% getDegrees (SUMO)
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
%	[N,D] = getDegrees(s, n)
%
% Description:
%	Return a total of `n' degrees, for numerator
%	and denominator combined. A call to update with
%	an argument bigger than `n' must be done first.
%	Example:
%	If s.degrees = [ 0 0 ; 0 1 ; 1 0 ; 0 2 ; 1 1 ; 2 0 ];
%	and flags = [ 0 1 ] then getDegrees( 6 ) returns
%	 N = [ 0 0 ; 0 1 ; 1 0 ; 0 2 ]
%	and
%	 D = [ 0 0 ; 1 0 ]
%	for a total of 6 degree pairs and with D(2,:) all zero
%	(because flag(2) == 1)

if n <= 0
	N = zeros(0, s.dimension);
	D = zeros(0, s.dimension);
else
	index = find(n <= s.sums);
	% TODO: this if is a hack of mine (Dirk) to work around a crash, not sure if it is correct though?
	if(length(index) == 0)
	  N = zeros(0, s.dimension);
	  D = zeros(0, s.dimension);
	else
	  index = index(1);
	  N = s.degrees(1:index,:);
	  D = s.degrees(find(s.marks(1:index)),:);
	  
	  if s.sums(index) > n
		  D = D(1:end-1,:);
	  end
	end
end
